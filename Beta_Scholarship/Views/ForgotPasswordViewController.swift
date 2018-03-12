//
//  ForgotPasswordViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/21/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendCodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureButton(button: backButton, view: self)
        configureButton(button: sendCodeButton, view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressedDown(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    @IBAction func backButtonReleased(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    }
    
    @IBAction func sendCodeButtonPressedDown(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    @IBAction func sendCodeButtonReleased(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        performSegue(withIdentifier: "forgotPasswordToResetPassword", sender: sender)
    }
}
