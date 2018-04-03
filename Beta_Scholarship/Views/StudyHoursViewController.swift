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
import GooglePlacePicker

class StudyHoursViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var ringView1: MKRingProgressView!
    @IBOutlet weak var ringView2: MKRingProgressView!
    @IBOutlet weak var ringView3: MKRingProgressView!
    
    @IBOutlet weak var hoursForWeek: UILabel!
    @IBOutlet weak var hoursForDay: UILabel!
    @IBOutlet weak var hoursForSemester: UILabel!
    
    @IBOutlet weak var studyLogButton: UIButton!
    @IBOutlet weak var startStudyingButton: UIButton!

    @IBOutlet weak var timerButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var initialLocation:CLLocationCoordinate2D!
    var locationName:String?
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
    //let cache = NSCache<NSString, userInformation>()
    var myPlace:GMSPlace?
    var classDescription: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadDefaults()

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
        loadDefaults()
        refresh()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func openPlacePicker() {
        // Create a place picker. Attempt to display it as a popover if we are on a device which
        // supports popovers.
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        placePicker.modalPresentationStyle = .popover
        //placePicker.popoverPresentationController?.sourceView = self
        //placePicker.popoverPresentationController?.sourceRect = self.bounds

        // Display the place picker. This will call the delegate methods defined below when the user
        // has made a selection.
        self.present(placePicker, animated: true, completion: nil)
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
                    /*if let cachedUserInfo = self.cache.object(forKey: "CachedObject") {
                        // use the cached version
                        print("getting cached userinfo")
                        self.userInfo = cachedUserInfo
                    } else {
                        // create it from scratch then store in the cache
                        print("cacheing") */
                    self.userInfo = userInformation(self.response!)
                        //self.cache.setObject(self.userInfo!, forKey: "CachedObject")
                    //}
                    
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
        let studying = defaults.object(forKey: "studying") as? Bool ?? Bool()
        print("studying: \(studying)")
        if (!studying) {
            timerButton.isEnabled = false
        } else {
            timerButton.isEnabled = true
        }

        locationName = defaults.string(forKey: "locationName") as? String ?? String()
        classDescription = defaults.string(forKey: "classDescription")  as? String ?? String()
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
            self.ringView1.animateTo(currentForWeek / goalForWeek * 100)
            self.ringView2.animateTo(currentForDay / goalForDay * 100)
            self.ringView3.animateTo(currentForSemester / goalForSemester * 100)
            
            //print("currentForDay: " + String(format: "%02.1lf", currentForDay))
            
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
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                let alertController = UIAlertController(title: "Location Services Required",
                                                        message: "Location services permissions were not authorized. Please enable it in Settings to start studying.",
                                                        preferredStyle: .alert)
                
                let settingsAction = UIAlertAction(title: "Settings", style: .cancel) { (alertAction) in
                    
                    // THIS IS WHERE THE MAGIC HAPPENS!!!!
                    if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.open(appSettings, completionHandler: nil)
                    }
                }
                alertController.addAction(settingsAction)
                
                self.present(alertController, animated: true, completion: nil)
            case .authorizedAlways, .authorizedWhenInUse:
                openPlacePicker()
            }
        }
    }

    func compareCoordinates(_ cllc2d1 : CLLocationCoordinate2D, _ cllc2d2 : CLLocationCoordinate2D) -> Bool {

        let epsilon = 0.00075

        print("fabs 1: \(fabs(cllc2d1.latitude - cllc2d2.latitude))")
        print("fabs 2: \(fabs(cllc2d1.longitude - cllc2d2.longitude))")

        return  fabs(cllc2d1.latitude - cllc2d2.latitude) <= epsilon && fabs(cllc2d1.longitude - cllc2d2.longitude) <= epsilon
    }

    
    @IBAction func unwindToStudyHours(segue:UIStoryboardSegue) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        /*if segue.identifier == "Study Hours To Timer" {
            let timerViewController = segue.destination as! TimerViewController
            if sender != nil {
                timerViewController.place = myPlace
                timerViewController.classDescription = classDescription
            } else {
                print("sender was nil!")
            }
        } */
        if segue.identifier == "Study Hours To Class" {
            let selectClassViewController = segue.destination as! SelectClassViewController
            if sender != nil {
                selectClassViewController.place = myPlace
                print("myPlace2: \(myPlace)")
            } else {
                print("sender was nil!")
            }
        }
    }

    
}

extension MKRingProgressView { 
    func animateTo(_ number : Double) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.7)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        
        self.progress = number/100
        
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



extension StudyHoursViewController : GMSPlacePickerViewControllerDelegate {

    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {

        // Google's Place
        myPlace = place

        // User's Current Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        print(locValue)
        initialLocation = locValue

        // If the user picks a location that they are not at, send alert notify them of that
        if(!self.compareCoordinates(place.coordinate, locValue)){

            let alert = UIAlertController(title: "Invalid Location!", message: "The location you chose is too far away from your current location.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default) { (alertAction) in
                // Dismiss old view
                viewController.dismiss(animated: false, completion: nil)
                let config = GMSPlacePickerConfig(viewport: nil)
                let placePicker = GMSPlacePickerViewController(config: config)
                placePicker.delegate = self
                placePicker.modalPresentationStyle = .popover

                // Add new one
                self.present(placePicker, animated: false, completion: nil)
            })

            viewController.present(alert, animated: true, completion: nil)
        }
        else {
            performSegue(withIdentifier: "Study Hours To Class", sender: self)
            viewController.dismiss(animated: true, completion: nil)
        }

    }

    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
        // In your own app you should handle this better, but for the demo we are just going to log
        // a message.
        NSLog("An error occurred while picking a place: \(error)")
    }

    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        NSLog("The place picker was canceled by the user")

        // Dismiss the place picker.
        viewController.dismiss(animated: true, completion: nil)
    }
}
