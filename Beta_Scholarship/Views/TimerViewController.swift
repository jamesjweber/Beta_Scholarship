//
//  TimerViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/14/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import MKRingProgressView
import Foundation
import EPSignature
import AWSDynamoDB
import AWSCognitoIdentityProvider
import GooglePlacePicker
import AWSS3

class TimerViewController: UIViewController, EPSignatureDelegate{

    @IBOutlet weak var timerText: UILabel! {
        didSet {
            timerText.font = UIFont.monospacedDigitSystemFont(ofSize: timerText.font.pointSize, weight: UIFont.Weight.ultraLight)
        }
    }
    @IBOutlet weak var timerRing: MKRingProgressView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var startStudyingSubmitHoursButton: UIButton!
    @IBOutlet weak var discardHoursButton: UIButton!
    
    @IBOutlet weak var imgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgViewSignature: UIImageView!

    let bucketName = "beta-mu-signature-bucket"

    var proboLevel: String?
    var firstName: String?
    var lastName: String?

    var timerCounter: Timer?
    var paused = true {
        didSet {
            defaults.set(paused, forKey: "paused")
        }
    }
    var studying = false {
        didSet {
            defaults.set(studying, forKey: "studying")
        }
    }
    var totalTime: Int = 0 {
        didSet {
            defaults.set(totalTime, forKey: "totalTime")
            print("newTotalTime: \(totalTime)")
        }
    }
    let defaults = UserDefaults.standard
    var segueTime:Double?

    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var response: AWSCognitoIdentityUserGetDetailsResponse?

    var classDescription: String?
    var locationName: String?
    var place: GMSPlace?
    var signatureURL: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // S3 Intializations
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1, identityPoolId:"us-east-1:bb023064-cbc1-40da-8cfc-84cc04d5485f")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        // Other AWS Stuff
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }

        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
            })
            return nil
        }


        pauseButton.isEnabled = false
        timerRing.resetAnimation()

        loadDefaults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(studying && !paused){
            defaults.set(Calendar.current.component(.nanosecond, from: Date()), forKey: "segueTime")
        }
        if(timerCounter != nil){
            timerCounter!.invalidate()
            timerCounter = nil
        }
    }

    func loadDefaults() {
        locationName = defaults.string(forKey: "locationName") as? String ?? String()
        classDescription = defaults.string(forKey: "classDescription")  as? String ?? String()

        paused = defaults.object(forKey: "paused") as? Bool ?? Bool()
        studying = defaults.object(forKey: "studying") as? Bool ?? Bool()
        totalTime = defaults.object(forKey: "totalTime") as? Int ?? Int()
        segueTime = defaults.object(forKey: "segueTime") as? Double ?? Date().timeIntervalSince1970

        print("----------- DEFAULTS ------------")
        print("paused: \(paused)")
        print("studying: \(studying)")
        print("totalTime: \(totalTime)")
        print("segueTime: \(segueTime)")


        if (studying) {
            startStudyingSubmitHoursButton.setTitle("Submit Hours", for: .normal)
            formatTime(time: totalTime)
            timerRing.animateTo(Double(totalTime) / 36)
            pauseButton.isEnabled = true
            discardHoursButton.isHidden = false
            if(paused) {
                pauseButton.setImage(UIImage(named: "Play"), for: .normal)
            } else {
                totalTime += additionalTime(segueTime!)
                startTimer()
                pauseButton.setImage(UIImage(named: "Pause"), for: .normal)
            }
        }
    }


    func additionalTime(_ segueTime: Double) -> Int {
        let currentTime = Date().timeIntervalSince1970

        let difference: Int = Int(currentTime - segueTime)
        
        print("currentTime: \(currentTime)")
        print("segueTime: \(segueTime)")
        print("difference: \(difference)")

        return Int(difference)
    }

    @IBAction func startStudyingSubmitHoursPressed(_ sender: Any) {
        if (startStudyingSubmitHoursButton.titleLabel?.text! == "Start Studying") {

            studying = true
            startStudyingSubmitHoursButton.setTitle("Submit Hours", for: .normal)
            discardHoursButton.isHidden = false
            pauseButton.isEnabled = true
            paused = false
            pauseButton.setImage(UIImage(named: "Pause"), for: .normal)
            startTimer()
            return

        } else if (startStudyingSubmitHoursButton.titleLabel?.text! == "Submit Hours") {

            let pauseState = paused
            self.stopTimer()

            let alertController = UIAlertController(title: "Are you sure?", message: "Please confirm that you would like to submit hours", preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in

                if(!pauseState) { self.startTimer() } // If it was not paused going in, unpause

            })
            alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: logHours))

            self.present(alertController, animated: true, completion: nil)
            return
        }
    }

    @IBAction func pausePressed(_ sender: Any) {
        if (!paused) { stopTimer(); pauseButton.setImage(UIImage(named: "Play"), for: .normal) }
        else { startTimer(); pauseButton.setImage(UIImage(named: "Pause"), for: .normal) }
    }
    
    @IBAction func discardPressed(_ sender: Any) {
        let pauseState = paused
        self.stopTimer()
        
        let alertController = UIAlertController(title: "Are you sure?", message: "Please confirm that you would like to DISCARD these hours", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            
            if(!pauseState) { self.startTimer() } // If it was not paused going in, unpause
            
        })
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default) { (alertAction) in
            self.resetTimer()
            self.performSegue(withIdentifier: "unwindSegueToStudyHours", sender: self)
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToTimer(segue:UIStoryboardSegue) {
        
    }
    
    func startTimer() {
        paused = false
        if (timerCounter == nil){
            timerCounter = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(TimerViewController.updateCounter), userInfo: nil, repeats: true)
        } else {
            timerCounter!.invalidate()
            timerCounter = nil
        }
    }

    func stopTimer() {
        paused = true
        if(timerCounter != nil){
            timerCounter!.invalidate()
            timerCounter = nil
        }
    }
    
    func resetTimer() {
        self.startStudyingSubmitHoursButton.setTitle("Start Studying", for: .normal)
        self.timerText.text! = "00:00:00:00"
        self.timerRing.resetAnimation()
        self.pauseButton.setImage(UIImage(named: "Blank"), for: .normal)
        self.pauseButton.isEnabled = false
        self.discardHoursButton.isHidden = true
        self.totalTime = 0
        self.studying = false
    }
    


    @objc func updateCounter() {
        formatTime(time: totalTime)
        totalTime += 1
        timerRing.animateTo(Double(totalTime) / 36)
        defaults.set(Date().timeIntervalSince1970, forKey: "segueTime")
    }

    func formatTime(time: Int) -> Double {

        var localTime = time

        let days = localTime / 86400 // seconds in a day
        localTime -= days * 86400 // subtract time for days

        let hours = localTime / 3600 // seconds in an hour
        localTime -= hours * 3600 // subtract time for hours

        let minutes = localTime / 60 // seconds in a minute
        localTime -= minutes * 60

        let seconds = localTime // remaining time will contain seconds

        self.timerText.text! = String(format: "%02d", days)
                + ":" + String(format: "%02d", hours)
                + ":" + String(format: "%02d", minutes)
                + ":" + String(format: "%02d", seconds)

        return (Double(days * 24 + hours) + Double(Int(minutes)/3)/20)
    }

    func logHours(_ alert: UIAlertAction) {
        if(timerCounter != nil){
            timerCounter!.invalidate()
            timerCounter = nil
        }
        startStudyingSubmitHoursButton.setTitle("Start Studying", for: .normal)

        for index in 1..<(self.response?.userAttributes?.count)! {
            var userAttribute = self.response?.userAttributes![index]

            if(userAttribute?.name! == "custom:probo_level") {
                proboLevel = userAttribute?.value!
            }
            if(userAttribute?.name! == "given_name") {
                firstName = userAttribute?.value!
            }
            if(userAttribute?.name! == "family_name") {
                lastName = userAttribute?.value!
            }

        }

        print("b4 ep signature")

        let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: false)
        signatureVC.subtitleText = "I affirm that \(firstName! + " " + lastName!) has studied \(formatTime(time: totalTime)) hours at \(locationName!)"
        signatureVC.title = firstName! + " " + lastName!
        let nav = UINavigationController(rootViewController: signatureVC)
        present(nav, animated: true, completion: nil)

        print("after ep signature")
    }

    func epSignature(_: EPSignatureViewController, didSign signatureImage : UIImage, boundingRect: CGRect) {
        print(signatureImage)
        imgViewSignature.image = signatureImage
        imgWidthConstraint.constant = boundingRect.size.width
        imgHeightConstraint.constant = boundingRect.size.height

        print("EPSigz")
        if let img : UIImage = imgViewSignature.image! as UIImage{
            let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("image.png")
            let imageData: NSData = UIImagePNGRepresentation(img)! as NSData
            imageData.write(toFile: path as String, atomically: true)

            // once the image is saved we can use the path to create a local fileurl
            let url:NSURL = NSURL(fileURLWithPath: path as String)

            print("url: \(url)")

            let date = Date()
            let calendar = Calendar.current

            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)



            let fileName = lastName! + firstName! + "\(month)" + "-" + "\(day)" + "-" + "\(year)" + "-" + "\(hour)" + " " +  "\(minute)" + "Signature"

            uploadFile(with: fileName, type: "PNG", url: url)

            signatureURL = "https://s3.amazonaws.com/beta-mu-signature-bucket/" + fileName + ".PNG"
        }

        print("submiting data yeet")
        submitData()
        print("then reset timer")
        resetTimer()

        self.performSegue(withIdentifier: "unwindSegueToStudyHours", sender: self)
    }

    func uploadFile(with resource: String, type: String, url: NSURL) {
        let key = "\(resource).\(type)"
        let request = AWSS3TransferManagerUploadRequest()!

        request.bucket = bucketName
        request.key = key
        request.body = url as URL
        request.acl = .publicReadWrite

        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in

            if let error = task.error {
                print(error)
            }
            if task.result != nil {
                print("Uploaded \(key)")
            }

            return nil
        }

    }

    func submitData() {

        print("submit data")

        let date = Date() // now
        let cal = Calendar.current
        let day:Int = cal.ordinality(of: .day, in: .year, for: date)!
        let hour = cal.component(.hour, from: date)
        let minute = cal.component(.minute, from: date)

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM/dd/yy hh:mm:ss"

        let tableRow = studyHours()
        tableRow?.Date_And_Time = "\(dateFormatterGet.string(from: date))"
        tableRow?.Hours = formatTime(time: totalTime) as NSNumber?
        tableRow?.NameOfUser = firstName! + " " + lastName! as String?
        tableRow?.Probo_Level = proboLevel! as String?
        tableRow?.Class = classDescription as String?
        tableRow?.Location = locationName
        tableRow?.Week = (day/7 - 1) as NSNumber?
        tableRow?.SigURL = signatureURL

        self.insertTableRow(tableRow!)

        print("logged!")
    }

    func insertTableRow(_ tableRow: studyHours) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()

        dynamoDBObjectMapper.save(tableRow) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
                    if let error = task.error as NSError? {
                        print("Error: \(error)")

                        let alertController = UIAlertController(title: "Failed to submit study hours.", message: "Text the scholarship chair.", preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "Succeeded", message: "Successfully submitted study hours.", preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)

                        //self.dataChanged = true
                    }
                    return nil
                })
    }

}
