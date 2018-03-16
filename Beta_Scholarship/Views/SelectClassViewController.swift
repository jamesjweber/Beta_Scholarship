//
//  SelectClassViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/13/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import GooglePlacePicker

class SelectClassViewController: UIViewController {

    //private let place: GMSPlace
    var place: GMSPlace?
    var locationName: String?

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var SISessionButton: UIButton!
    @IBOutlet weak var OfficeHoursButton: UIButton!
    @IBOutlet weak var classTextField: RoundedTextField! {
        didSet {
            defaults.set(classTextField.text!, forKey: "classDescription")
        }
    }
    @IBOutlet weak var hiddenAlertLabel: UILabel!

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadDefaults()

        if let myPlace = place {
            locationName = place?.name
            defaults.set(locationName, forKey: "locationName")
        }

        configureButton(button: nextButton, view: self)
        configureButton(button: SISessionButton, view: self)
        configureButton(button: OfficeHoursButton, view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadDefaults() {
        locationName = defaults.string(forKey: "locationName") as? String ?? String()
        classTextField.text! = defaults.string(forKey: "classDescription") as? String ?? String()
    }
    
    @IBAction func nextSelected(_ sender: Any) {
        if(classTextField.text != "") {
            defaults.set(classTextField.text!, forKey: "classDescription")
            performSegue(withIdentifier: "Select Class To Timer", sender: sender)
        } else {
            hiddenAlertLabel.text = "Class Name is Required!"
            hiddenAlertLabel.isHidden = false
        }
    }
    
    @IBAction func SISessionSelected(_ sender: Any) {
        classTextField.text = "SI Session"
        defaults.set(classTextField.text!, forKey: "classDescription")
        performSegue(withIdentifier: "Select Class To Timer", sender: sender)
    }
    
    @IBAction func OfficeHoursSelected(_ sender: Any) {
        classTextField.text = "Office Hours"
        defaults.set(classTextField.text!, forKey: "classDescription")
        performSegue(withIdentifier: "Select Class To Timer", sender: sender)
    }
    
    @IBAction func unwindToSelectClass(segue:UIStoryboardSegue) {

    }

    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        /*if segue.identifier == "Select Class To Timer" {
            let timerViewController = segue.destination as! TimerViewController
            if sender != nil {
                timerViewController.place = place
                timerViewController.classDescription = classTextField.text!
            } else {
                print("sender was nil!")
            }
        } */

        /* if segue.identifier == "Unwind Select Class To Study Hours" {
            let studyHoursViewController = segue.destination as! StudyHoursViewController
            if sender != nil {
                studyHoursViewController.myPlace = place
                studyHoursViewController.classDescription = classTextField.text!
            } else {
                print("sender was nil!")
            }
        } */
    //}
}
