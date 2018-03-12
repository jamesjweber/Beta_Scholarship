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
    var name: String!
    
    var userInfo: userInformation = userInformation()
    var userHours = [studyHours]()
    
    var semesterHours: Double = 0
    var dayHours: Double = 0
    var weekHours: Double = 0

    let defaults = UserDefaults.standard
    
    let cache = NSCache<NSString, userInformation>()

    override func viewDidLoad() {
        locationManager.requestWhenInUseAuthorization()

        super.viewDidLoad()
        
        configureButton(button: studyLogButton, view: self)
        configureButton(button: startStudyingButton, view: self)
    }
    
    func setName() {
        
        print("userInfo: \(userInfo.fullName!)")
        
        name = "Corey Wogenstahl"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        resetRings()
        
        getUserInfoAndHours()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.updateRings(proboLevel: self.userInfo.probo_level ?? 0, userHours: self.userHours)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func getUserInfoAndHours() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.userInfo = userInformation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let response = appDelegate.response else {
                return
            }
            
            if let cachedUserInfo = self.cache.object(forKey: "CachedObject") {
                // use the cached version
                print("getting cached userinfo")
                self.userInfo = cachedUserInfo
            } else {
                // create it from scratch then store in the cache
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    print("cacheing")
                    self.userInfo = userInformation(response)
                    print("first name:: \(self.userInfo.given_name!)")
                    self.cache.setObject(self.userInfo, forKey: "CachedObject")
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setName()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
                let queryExpression = AWSDynamoDBQueryExpression()
                queryExpression.indexName = "NameOfUser"
                queryExpression.keyConditionExpression = "NameOfUser = :name AND Week <= :week" // test
                queryExpression.expressionAttributeValues = [":name" : self.name!, ":week" : 16]
                
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
                            
                        }
                    }
                    return nil
                })
            }
        }
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
        
        if userHours == nil {
            return (0.0001, 0.0001, 0.0001)
        }
        
        /*print("week hours: \(weekHours)")
        if weekHours > 0 || dayHours > 0 || semesterHours > 0 {
            weekHours = 0
            print("week hours:: \(weekHours)")
            dayHours = 0
            semesterHours = 0
        } */
            
        let cal = Calendar.current
        let day:Int = cal.ordinality(of: .day, in: .year, for: Date())!
        let currentWeek = (day/7 - 1)
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM/dd/yy"
        
        let date = "\(dateFormatterGet.string(from: Date()))"
        
        for log in userHours {
            semesterHours += (log.Hours?.doubleValue)!
            print("is \((log.Week?.intValue)!) == \(currentWeek)?")
            if (log.Week?.intValue)! == currentWeek {
                weekHours += (log.Hours?.doubleValue)!
                print("date: \(date)")
                
                if(date == log.Date_And_Time![0...7]) {
                    dayHours += (log.Hours?.doubleValue)!
                }
            }
        }
        
        
        
        
        print("week hours::: \(weekHours)")
        return (weekHours,dayHours,semesterHours)
    }
    
    /*class rings {
        let shapeLayer = CAShapeLayer()
        let trackLayer = CAShapeLayer()

        init(center: CGPoint, radius: Int, ringWidth: CGFloat, color: UIColor, percentage: Double) {
            let circularPath = UIBezierPath(arcCenter: center, radius: CGFloat(radius), startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi, clockwise: true)

            print("percentage: " + String(percentage))
            let rad = (CGFloat(percentage)*2*CGFloat.pi)
            print(rad)

            let circularPath2 = UIBezierPath(arcCenter: center, radius: CGFloat(radius), startAngle: -CGFloat.pi/2, endAngle: rad-CGFloat.pi/2, clockwise: true)

            self.addTrackLayer(path: circularPath.cgPath, color: color, ringWidth: ringWidth)

            shapeLayer.path = circularPath2.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor

            shapeLayer.shadowColor = UIColor.black.cgColor
            shapeLayer.shadowOffset = CGSize(width: -3.0, height: 3.0)
            shapeLayer.shadowOpacity = 0.3
            shapeLayer.shadowRadius = 8.0

            shapeLayer.strokeEnd = 0

            shapeLayer.lineCap = kCALineCapRound

            shapeLayer.strokeColor = color.cgColor

            shapeLayer.name = "shapeLayer"

            let modelName = Device()
            if (modelName.description == "iPhone 5s" || modelName.description == "iPhone SE" || modelName.description == "Simulator (iPhone 5s)") {
                shapeLayer.lineWidth = 10
            } else {
                shapeLayer.lineWidth = ringWidth
            }
        }


        func addTrackLayer(path:CGPath, color: UIColor, ringWidth: CGFloat) {
            // Track Layer
            trackLayer.path = path
            trackLayer.fillColor = UIColor.clear.cgColor

            trackLayer.strokeColor = color.withAlphaComponent(0.2).cgColor
            let modelName = Device()
            if (modelName.description == "iPhone 5s" || modelName.description == "iPhone SE" || modelName.description == "Simulator (iPhone 5s)") {
                trackLayer.lineWidth = 10
            } else {
                trackLayer.lineWidth = ringWidth
            }
            trackLayer.name = "trackLayer"
        }
    }

    func createRings() {
        let ringWidth1 = ringView1.bounds.width;
        print(ringWidth1)
        let ringHeight1 = ringView1.bounds.height;
        let ringWidth2 = ringView2.bounds.width;
        let ringHeight2 = ringView2.bounds.height;
        let ringWidth3 = ringView3.bounds.width;
        let ringHeight3 = ringView3.bounds.height;

        let ringWidth:CGFloat = 14;

        let ringCenter1 = CGPoint(
            x: ringWidth1/2,
            y: ringHeight1/2
        )
        let ringCenter2 = CGPoint(
            x: ringWidth2/2,
            y: ringHeight2/2
        )
        let ringCenter3 = CGPoint(
            x: ringWidth3/2,
            y: ringHeight3/2
        )

        let ring1 = rings(center: ringCenter1,
                          radius: Int(ringHeight1/2-ringWidth/2),
                          ringWidth: ringWidth,
                          color: Colors().red,
                          percentage: 8/12)

        let ring2 = rings(center: ringCenter2,
                          radius: Int(ringHeight1/2-ringWidth/2),
                          ringWidth: ringWidth,
                          color: Colors().blue,
                          percentage: 3.6/2.4)

        let ring3 = rings(center: ringCenter3,
                          radius: Int(ringHeight1/2-ringWidth/2),
                          ringWidth: ringWidth,
                          color: Colors().yellow,
                          percentage: 36/(12*16))

        let ringAnimation = CABasicAnimation(keyPath: "strokeEnd")
        ringAnimation.toValue = 1
        ringAnimation.duration = 0.7;
        ringAnimation.fillMode = kCAFillModeForwards
        ringAnimation.isRemovedOnCompletion = false
        ringAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        ringView1.layer.addSublayer(ring1.shapeLayer)
        ringView1.layer.addSublayer(ring1.trackLayer)
        ring1.shapeLayer.add(ringAnimation, forKey: "dummy")

        ringView2.layer.addSublayer(ring2.shapeLayer)
        ringView2.layer.addSublayer(ring2.trackLayer)
        ring2.shapeLayer.add(ringAnimation, forKey: "dummy")

        ringView3.layer.addSublayer(ring3.shapeLayer)
        ringView3.layer.addSublayer(ring3.trackLayer)
        ring3.shapeLayer.add(ringAnimation, forKey: "dummy")
    } */

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
