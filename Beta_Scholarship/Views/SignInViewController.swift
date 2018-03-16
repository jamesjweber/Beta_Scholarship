//
//  SignInViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/20/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import DeviceKit
import AWSCognitoIdentityProvider

class SignInViewController: UIViewController {

    // MARK: Objects
    @IBOutlet weak var welcomeText: UITextView!
    @IBOutlet weak var signInText: UITextView!
    @IBOutlet weak var usernameOrEmail: RoundedTextField!
    @IBOutlet weak var password: RoundedTextField!
    //@IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var usernameText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        changeTextForSmallDevices()
        configureButton(button: loginButton, view: self)
        configureButton(button: signUpButton, view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.password.text = nil
        self.usernameOrEmail.text = usernameText
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonPressedDown(_ sender: UIButton) {
        if (self.usernameOrEmail.text != "" && self.password.text != "") {
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.usernameOrEmail.text!, password: self.password.text! )
            self.passwordAuthenticationCompletion?.set(result: authDetails)
        } else {
            let alert = UIAlertController(title: "Missing information", message: "Please enter a valid user name and password", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alert.addAction(retryAction)
            self.present(alert, animated: true, completion: nil)
        }
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    @IBAction func loginButtonReleased(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    }
    
    @IBAction func signUpButtonPressedDown(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    @IBAction func signUpButtonReleased(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    }
    
    func changeTextForSmallDevices() {
        let modelName = Device()
        print("model: " + String(modelName.description))
        if (modelName.description == "iPhone 5s" || modelName.description == "iPhone SE" || modelName.description == "Simulator (iPhone 5s)") {
            welcomeText.text = ""
            welcomeText.font = UIFont(name: "AppleSDGothicNeo-Light" , size: 0)
            signInText.text  = ""
            signInText.font = UIFont(name: "AppleSDGothicNeo-Light" , size: 0)
        }
    }
}

extension SignInViewController: AWSCognitoIdentityPasswordAuthentication {

    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameText == nil) {
                self.usernameText = authenticationInput.lastKnownUsername
            }
        }
    }

    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: "Invalid Username or Password",
                        message: "Please try again",
                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)

                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.usernameOrEmail.text = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func unwindToSignIn(segue:UIStoryboardSegue) {
        
    }
}
