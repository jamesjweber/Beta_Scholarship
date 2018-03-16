//
//  YearAndMajorTableViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/24/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import DeviceKit
import AWSCognitoIdentityProvider
import AWSS3

class AppInfoViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var email: RoundedTextField!
    @IBOutlet weak var username: RoundedTextField!
    @IBOutlet weak var password: RoundedTextField!
    @IBOutlet weak var confirmPassword: RoundedTextField!

    var signInInfo: signInInformation?
    var pool: AWSCognitoIdentityUserPool?
    var sentTo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let signIn = signInInfo {
            print("signIn.beta.housePositions: \(signIn.beta.housePositions)")
        }

        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)

        // S3 Intializations
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1, identityPoolId:"us-east-1:bb023064-cbc1-40da-8cfc-84cc04d5485f")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        configureButton(button: nextButton, view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func emailDidChange(_ sender: RoundedTextField) {
        signInInfo?.contact.appEmail = email.text!
    }
    @IBAction func usernameDidChange(_ sender: RoundedTextField) {
        signInInfo?.other.username = username.text!
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if checkTextFields() {
            if(checkPasswordForRequirement()) {
                if (checkMatchingPassword()) {
                    
                    // MARK: Default Attributes
                    var attributes = [AWSCognitoIdentityUserAttributeType]()
                    
                    if let firstNameValue = signInInfo?.name.first {
                        let firstName = AWSCognitoIdentityUserAttributeType()
                        firstName?.name = "given_name"
                        firstName?.value = firstNameValue
                        attributes.append(firstName!)
                    }
                    
                    if let lastNameValue = signInInfo?.name.last {
                        let lastName = AWSCognitoIdentityUserAttributeType()
                        lastName?.name = "family_name"
                        lastName?.value = lastNameValue
                        attributes.append(lastName!)
                    }
                    
                    if let profilePicURLValue = signInInfo?.other.profilePicURL {
                        let profilePicURL = AWSCognitoIdentityUserAttributeType()
                        profilePicURL?.name = "custom:profile_pic_url"
                        profilePicURL?.value = profilePicURLValue
                        attributes.append(profilePicURL!)
                    }
                    
                    if let birthDateValue = signInInfo?.other.birthdate {
                        let birthDate = AWSCognitoIdentityUserAttributeType()
                        birthDate?.name = "birthdate"
                        birthDate?.value = birthDateValue
                        attributes.append(birthDate!)
                    }
                    
                    if let emailValue = signInInfo?.contact.appEmail {
                        let email = AWSCognitoIdentityUserAttributeType()
                        email?.name = "email"
                        email?.value = emailValue
                        attributes.append(email!)
                    }
                    
                    if let phoneValue = signInInfo?.contact.phone {
                        let phone = AWSCognitoIdentityUserAttributeType()
                        phone?.name = "phone_number"
                        phone?.value = phoneValue
                        attributes.append(phone!)
                    }
                    
                    if let streetAddress = signInInfo?.address.street, let city = signInInfo?.address.city, let state = signInInfo?.address.state, let zip = signInInfo?.address.zip {
                        
                        let addressValue = formatAddress(streetAddress, city: city, state: state, zip: zip)
                        let address = AWSCognitoIdentityUserAttributeType()
                        address?.name = "address"
                        address?.value = addressValue
                        attributes.append(address!)
                    }
                    
                    // MARK: Custom Attribute
                    if let contactEmailValue = signInInfo?.contact.contactEmail {
                        let contactEmail = AWSCognitoIdentityUserAttributeType()
                        contactEmail?.name = "custom:contact_email"
                        contactEmail?.value = contactEmailValue
                        attributes.append(contactEmail!)
                    }
                    
                    if let yearValue = signInInfo?.school.year {
                        let year = AWSCognitoIdentityUserAttributeType()
                        year?.name = "custom:year"
                        year?.value = yearValue
                        attributes.append(year!)
                    }
                    
                    if let majorValue = signInInfo?.school.major {
                        let major = AWSCognitoIdentityUserAttributeType()
                        major?.name = "custom:major"
                        major?.value = majorValue
                        attributes.append(major!)
                    }
                    
                    if let brotherStatusValue = signInInfo?.beta.brotherStatus {
                        let brotherStatus = AWSCognitoIdentityUserAttributeType()
                        brotherStatus?.name = "custom:brother_status"
                        brotherStatus?.value = brotherStatusValue
                        attributes.append(brotherStatus!)
                    }
                    
                    if let pinNumValue = signInInfo?.beta.pin {
                        let pinNum = AWSCognitoIdentityUserAttributeType()
                        pinNum?.name = "custom:pin_number"
                        pinNum?.value = pinNumValue
                        attributes.append(pinNum!)
                    }

                    if let proboLevelValue = signInInfo?.beta.proboLevel {
                        let proboLevel = AWSCognitoIdentityUserAttributeType()
                        proboLevel?.name = "custom:probo_level"
                        proboLevel?.value = proboLevelValue
                        attributes.append(proboLevel!)
                    }

                    if let userHousePositionsValue = signInInfo?.beta.housePositions {
                        let housePositions = AWSCognitoIdentityUserAttributeType()
                        housePositions?.name = "custom:house_positions"
                        housePositions?.value = userHousePositionsValue
                        attributes.append(housePositions!)
                    }

                    let userInfoString: String = "First: \((signInInfo?.name.first!)!)\n" +
                            "Last: \((signInInfo?.name.last!)!)\n" +
                            "Birthday: \((signInInfo?.other.birthdate!)!)\n" +
                            "Contact Email: \((signInInfo?.contact.contactEmail!)!)\n" +
                            "Phone: \((signInInfo?.contact.phone!)!)\n" +
                            "Address: \((signInInfo?.address.street!)!) \((signInInfo?.address.city!)!), " +
                            "\((signInInfo?.address.state)!) \((signInInfo?.address.zip)!)\n" +
                            "Year: \((signInInfo?.school.year!)!)\n" +
                            "Major: \((signInInfo?.school.major!)!)\n" +
                            "Brother Status: \((signInInfo?.beta.brotherStatus!)!)\n" +
                            "Pin Number: \((signInInfo?.beta.pin ?? "") ?? "")\n" +
                            "Probo Level: \((signInInfo?.beta.proboLevel!)!)\n" +
                            "House Positions: \((signInInfo?.beta.housePositions!)!)"

                    func handlerConfirmed () {

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            print("signing up user")
                            self.pool?.signUp(self.username.text!, password: self.password.text!, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task) -> Any? in
                                guard let strongSelf = self else { return nil }
                                DispatchQueue.main.async(execute: {
                                    if let error = task.error as NSError? {
                                        let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                message: error.userInfo["message"] as? String,
                                                preferredStyle: .alert)
                                        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                                        alertController.addAction(retryAction)

                                        self?.present(alertController, animated: true, completion:  nil)
                                    } else if let result = task.result  {
                                        // handle the case where user has to confirm his identity via email / SMS
                                        if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                                            strongSelf.sentTo = result.codeDeliveryDetails?.destination
                                            strongSelf.performSegue(withIdentifier: "confirmSignUpSegue", sender:sender)
                                        } else {
                                            let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                                        }
                                    }

                                })
                                return nil
                            }
                        }

                        print("Sign up confirmed")
                    }

                    let alertController = UIAlertController(title: "Confirm Details", message: userInfoString, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Confirm", style: .default, handler: {action in handlerConfirmed()})
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion:  nil)
                }
            }
        } else {
            let alert = UIAlertController(title: "Missing Information", message: "Please fill out ALL fields", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(Ok)
            self.present(alert, animated: true, completion: nil)
        }

    }

    func formatAddress(_ streetAddress: String, city: String, state: String, zip: String) -> String {

        let formattedAddress = streetAddress + " " + city + ", " + state + " " + zip
        print(formattedAddress)

        return formattedAddress
    }

    func checkTextFields() -> Bool {
        if (!email.isEmpty() && !username.isEmpty() && !password.isEmpty() && !confirmPassword.isEmpty()) {
            return true
        }
        return false
    }

    func checkPasswordForRequirement() -> Bool {
        if ((password.text?.count)! < 8) {
            let alert = UIAlertController(title: "Modify Password", message: "Passwords must be 8 characters or longer", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(Ok)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        var capitalTest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        var capitalResult = capitalTest.evaluate(with: password.text ?? "")
        print("\(capitalResult)")
        
        let lowercaseLetterRegEx  = ".*[A-Z]+.*"
        var lowercaseTest = NSPredicate(format:"SELF MATCHES %@", lowercaseLetterRegEx)
        var lowercaseResult = lowercaseTest.evaluate(with: password.text ?? "")
        print("\(lowercaseResult)")
        
        
        let numberRegEx  = ".*[0-9]+.*"
        var numberTest = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        var numberResult = numberTest.evaluate(with: password.text ?? "")
        print("\(numberResult)")

        if (!(capitalResult && lowercaseResult && numberResult)) {
            let alert = UIAlertController(title: "Modify Password", message: "Passwords must contain at least one number and one uppercase letter", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(Ok)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }

    func checkMatchingPassword() -> Bool {
        if (password.text != confirmPassword.text) {
            let alertController = UIAlertController(title: "Passwords Don't Match",
                    message: "Password fields must match for registration.",
                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpConfirmationViewController = segue.destination as? ConfirmSignUpViewController {
            signUpConfirmationViewController.sentTo = self.sentTo
            signUpConfirmationViewController.user = self.pool?.getUser(self.username.text!)
        }
    }
}
