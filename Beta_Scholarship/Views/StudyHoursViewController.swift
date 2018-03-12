//
//  StudyHoursViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/27/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import DeviceKit
import CoreLocation
import GooglePlacePicker
import MKRingProgressView
import AWSDynamoDB
import AWSCognitoIdentityProvider

class StudyHoursViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var ringView1: MKRingProgressView!
    @IBOutlet weak var ringView2: MKRingProgressView!
    @IBOutlet weak var ringView3: MKRingProgressView!
    
    @IBOutlet weak var hoursForWeek: UILabel!
    @IBOutlet weak var hoursForDay: UILabel!
    @IBOutlet weak var hoursForSemester: UILabel!
    
    @IBOutlet weak var studyLogButton: UIButton!
    @IBOutlet weak var startStudyingButton: UIButton!

    let locationManager = CLLocationManager()
    var initialLocation:CLLocationCoordinate2D!
    var locationName:String!
    var locationSet: Bool!
    
    var credentialsProvider: AWSCognitoCredentialsProvider?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var name: String!
    
    var userInfo: userInformation?
    var userHours = [studyHours]()
    
    var semesterHours: Double = 0
    var dayHours: Double = 0
    var weekHours: Double = 0

    let defaults = UserDefaults.standard
    
    let cache = NSCache<NSString, userInformation>()

    override func viewDidLoad() {
        locationManager.requestWhenInUseAuthorization()

        super.viewDidLoad()
        
        // S3 Intializations
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1, identityPoolId:"us-east-1:bb023064-cbc1-40da-8cfc-84cc04d5485f")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        
        configureButton(button: studyLogButton, view: self)
        configureButton(button: startStudyingButton, view: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        self.resetRings()
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                if let response = self.response {
                    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                    //
                    // This section will get the user's info and save it in a local cache to save
                    // loading time. The user's info requires that self.response be fully loaded from
                    // task.result before it can get user info.
                    //
                    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                    if let cachedUserInfo = self.cache.object(forKey: "CachedObject") {
                        // use the cached version
                        print("getting cached userinfo")
                        self.userInfo = cachedUserInfo
                    } else {
                        // create it from scratch then store in the cache
                        print("cacheing")
                        self.userInfo = userInformation(self.response!)
                        self.cache.setObject(self.userInfo!, forKey: "CachedObject")
                    }
                    
                    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                    //
                    // This section queries our DynamoDB table, which contains all of the hours for
                    // the users. It will specifically query the hours for the given user for this
                    // semester. It wil automatically update, so if I manually change someone's
                    // hours it will remove the previous hours, and will add the correct hours to
                    // their hours.
                    //
                    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                    
                    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
                    let queryExpression = AWSDynamoDBQueryExpression()
                    queryExpression.indexName = "NameOfUser"
                    queryExpression.keyConditionExpression = "NameOfUser = :name AND Week <= :week" // test
                    queryExpression.expressionAttributeValues = [":name" : self.userInfo?.fullName! as Any, ":week" : 16]
                    
                    dynamoDBObjectMapper.query(studyHours.self, expression: queryExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
                        if let error = task.error as NSError? {
                            print("The request failed. Error: \(error)")
                        } else if let paginatedOutput = task.result {
                            //print("before for")
                            for item in paginatedOutput.items as! [studyHours] {
                                //print("item: \(item)")
                                if (!self.userHours.contains(item)) {
                                    //print("Date: \(item.Date_And_Time!) :\(item.Hours!)")
                                    
                                    for ind in 0..<self.userHours.count {
                                        if(self.userHours[ind].Date_And_Time == item.Date_And_Time) {
                                            self.userHours.remove(at: ind)
                                            print("Removed!")
                                        }
                                    }
                                    self.userHours.append(item)
                                }
                                
                                // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                                //
                                // The rings are subsequently updated given the users probation level (which will
                                // give us an idea of how many hours they need to reach for the week), and given
                                // the actual hours the user has studied for that day/week/semester. These hours
                                // are calculated from the userHours variable.
                                //
                                // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                                
                                self.updateRings(proboLevel: self.userInfo?.probo_level ?? 0, userHours: self.userHours)
                            }
                        }
                        return nil
                    })
                    
                } else {
                    print("Error getting response")
                }
            })
            return nil
        }
    }

    func loadDefaults() {
        //startTime = defaults.object(forKey: "startTime") as? [Int] ?? [Int]() //studying = defaults.object(forKey: "studying") as? Bool ?? false //paused = defaults.object(forKey: "paused") as? Bool ?? false //classDescription = defaults.object(forKey: "className") as? String ?? String() //diffTime = defaults.object(forKey: "diffTime") as? [Int] ?? [Int]() //pauseTime = defaults.object(forKey: "pauseTime") as? [Int] ?? [Int]() //timer.text! = defaults.object(forKey: "timerText") as? String ?? String()
        locationName = defaults.object(forKey: "locationName") as? String ?? String()
    }
    
    func resetRings() {
        ringView1.resetAnimation()
        ringView2.resetAnimation()
        ringView3.resetAnimation()
        hoursForDay.text! = "00"
        hoursForWeek.text! = "00"
        hoursForSemester.text! = "00"
    }
    
    func updateRings(proboLevel: Int, userHours: [studyHours]) {
        
        var goalForDay: Double
        var goalForWeek: Double
        var goalForSemester: Double
        
        switch proboLevel {
            case 1:
                goalForWeek = 5
                break
            case 2:
                goalForWeek = 8
                break
            case 3:
                goalForWeek = 12
                break
            default:
                goalForWeek = 10
        }
        
        goalForDay = goalForWeek / 5
        goalForSemester = goalForWeek * 16
        
        let (currentForWeek,currentForDay,currentForSemester) = calcMyCumulativeHours(userHours)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.ringView1.animateTo(Int(currentForWeek / goalForWeek * 100))
            self.ringView2.animateTo(Int(currentForDay / goalForDay * 100))
            self.ringView3.animateTo(Int(currentForSemester / goalForSemester * 100))
            
            print("currentForDay: " + String(format: "%02.1lf", currentForDay))
            
            self.hoursForWeek.animateTo(currentForWeek,outOf: goalForWeek)
            self.hoursForDay.animateTo(currentForDay,outOf: goalForDay)
            self.hoursForSemester.animateTo(currentForSemester, outOf: goalForSemester)
        }
    }
    
    func calcMyCumulativeHours(_ userHours: [studyHours]) -> (Double, Double, Double) {
        
        var semesterHours:Double = 0
        var weekHours:Double = 0
        var dayHours:Double = 0
        
        let cal = Calendar.current
        let day:Int = cal.ordinality(of: .day, in: .year, for: Date())!
        let currentWeek = (day/7 - 1)
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM/dd/yy"
        
        let date = "\(dateFormatterGet.string(from: Date()))"
        
        for log in userHours {
            semesterHours += (log.Hours?.doubleValue)!
            if (log.Week?.intValue)! == currentWeek {
                weekHours += (log.Hours?.doubleValue)!
                if(date == log.Date_And_Time![0...7]) {
                    dayHours += (log.Hours?.doubleValue)!
                }
            }
        }
        
        return (weekHours,dayHours,semesterHours)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    @IBAction func startStudying(_ sender: Any) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        print(locValue)
        initialLocation = locValue
        
        let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        
        //let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        //mapView.settings.scrollGestures = false
        
        placePicker.pickPlace(callback: {(place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                // self.nameLabel.text = place.name
                // self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ").joined(separator: "\n")
                print(locValue)
                print("----------------------")
                print(place.name)
                self.locationName = place.name
                self.defaults.set(self.locationName, forKey: "locationName")
                print(place.coordinate)
                print("----------------------")
                print(self.compareCoordinates(place.coordinate, locValue))
                
                if(!self.compareCoordinates(place.coordinate, locValue)){
                    let alert = UIAlertController(title: "Invalid Location!", message: "The location you chose is too far away from your current location.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in  }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    self.locationSet = true
                }
            }
        })
    }

    func compareCoordinates(_ cllc2d1 : CLLocationCoordinate2D, _ cllc2d2 : CLLocationCoordinate2D) -> Bool {

        let epsilon = 0.00075

        print("fabs 1: \(fabs(cllc2d1.latitude - cllc2d2.latitude))")
        print("fabs 2: \(fabs(cllc2d1.longitude - cllc2d2.longitude))")

        return  fabs(cllc2d1.latitude - cllc2d2.latitude) <= epsilon && fabs(cllc2d1.longitude - cllc2d2.longitude) <= epsilon
    }


}

extension MKRingProgressView { 
    func animateTo(_ number : Int) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.7)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        
        self.progress = Double(number)/100
        
        CATransaction.commit()
    }
    
    func resetAnimation() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1)
        self.progress = 0
        
        CATransaction.commit()
    }
}

extension UILabel {
    func animateTo(_ number: Double, outOf: Double) {
        
        var totalHours = outOf
        
        if number < 0 || outOf <= 0 { return }
        if number > outOf { totalHours = number }
        
        for index in stride(from: 0, through: number + 0.01, by: 0.1) {
            let milliseconds:Int = Int(10 * index / totalHours * 100)
            let deadline : DispatchTime = .now() + .milliseconds(milliseconds)
            
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                if (Double(Int(index)) == index) {
                    self.text = String(format: "%02.0lf", index)
                } else if (totalHours < 40) {
                    self.text = String(format: "%02.1lf", index)
                }
            }
        }
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
