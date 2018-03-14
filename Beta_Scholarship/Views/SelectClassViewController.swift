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

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var SISessionButton: UIButton!
    @IBOutlet weak var OfficeHoursButton: UIButton!
    @IBOutlet weak var classTextField: RoundedTextField!
    @IBOutlet weak var hiddenAlertLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("place: \(place)")

        configureButton(button: nextButton, view: self)
        configureButton(button: SISessionButton, view: self)
        configureButton(button: OfficeHoursButton, view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextSelected(_ sender: Any) {
        if(classTextField.text != "") {
            performSegue(withIdentifier: "Select Class To Timer", sender: sender)
        } else {
            hiddenAlertLabel.text = "Class Name is Required!"
            hiddenAlertLabel.isHidden = false
        }
    }
    
    @IBAction func SISessionSelected(_ sender: Any) {
        performSegue(withIdentifier: "Select Class To Timer", sender: sender)
    }
    
    @IBAction func OfficeHoursSelected(_ sender: Any) {
        performSegue(withIdentifier: "Select Class To Timer", sender: sender)
    }
}
