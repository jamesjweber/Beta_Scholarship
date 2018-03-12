//
//  ResetPasswordViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/22/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mainMenu: UIButton!
    @IBOutlet weak var confirmationCodeText: RoundedTextField!
    @IBOutlet weak var newPasswordText: RoundedTextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureButton(button: backButton, view: self)
        configureButton(button: mainMenu, view: self)
        configureButton(button: resetPasswordButton, view: self)
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
    
    @IBAction func mainButtonPressedDown(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    @IBAction func mainButtonReleased(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    }
    
    @IBAction func resetPasswordButtonPressedDown(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    @IBAction func resetPasswordButtonReleased(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    }
    
}
