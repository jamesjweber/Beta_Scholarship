//
//  MyInfoViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/23/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import AWSS3

class MyInfoViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var firstName: RoundedTextField!
    @IBOutlet weak var lastName: RoundedTextField!
    @IBOutlet weak var birthdate: RoundedTextField!
    @IBOutlet weak var phone: RoundedTextField!
    @IBOutlet weak var email: RoundedTextField!
    @IBOutlet weak var streetAddress: RoundedTextField!
    @IBOutlet weak var city: RoundedTextField!
    @IBOutlet weak var state: RoundedTextField!
    @IBOutlet weak var zip: RoundedTextField!
    
    let picker = UIImagePickerController()
    var signInInfo: signInInformation?
    let bucketName = "betamuscholarship-deployments-mobilehub-1531569242"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if signInInfo == nil {
            signInInfo = signInInformation()
            addTargets()
        }
        
        configureButton(button: nextButton, view: self)
        picker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func photoTapped(_ sender: UITapGestureRecognizer) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Photo Library", comment: "Default action"), style: .default, handler: { (action) -> Void in
            self.picker.allowsEditing = true
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: "Default action"), style: .default, handler: { (action) -> Void in
            self.picker.allowsEditing = true
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)


    }
    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePic.contentMode = .scaleAspectFill
            profilePic.image = chosenImage
            setURL()
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addTargets() {
        //signInInfo!.name.first! = firstName.text!
        firstName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lastName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        birthdate.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phone.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        email.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        streetAddress.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        city.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        state.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        zip.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    func setURL () {
        if let img : UIImage = profilePic.image! as UIImage{

            // Disable next button
            nextButton.isEnabled = false

            let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("image.png")
            let imageData: NSData = UIImageJPEGRepresentation(img, 0.5)! as NSData
            imageData.write(toFile: path as String, atomically: true)

            // once the image is saved we can use the path to create a local fileurl
            let url:NSURL = NSURL(fileURLWithPath: path as String)

            let fileName = String(arc4random()) + "ProfPic"

            uploadFile(with: fileName, type: "jpeg", url: url)

            signInInfo?.other.profilePicURL = "https://s3.amazonaws.com/betamuscholarship-deployments-mobilehub-1531569242/" + fileName + ".jpeg"

            print("myURL: \(signInInfo?.other.profilePicURL)")


        }
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
            self.nextButton.isEnabled = true
            return nil
        }

    }
    
    @objc func textFieldDidChange(_ textField: RoundedTextField) {
        if (textField.placeholder! == "First Name") {
            signInInfo!.name.first = textField.text!
        } else if (textField.placeholder! == "Last Name") {
            signInInfo!.name.last = textField.text!
        } else if (textField.placeholder! == "Birthdate") {
            signInInfo!.other.birthdate = textField.text!
        } else if (textField.placeholder! == "Phone") {
            signInInfo!.contact.phone = textField.text!
        } else if (textField.placeholder! == "Email") {
            signInInfo!.contact.contactEmail = textField.text!
        } else if (textField.placeholder! == "(Home) Street Address") {
            signInInfo!.address.street = textField.text!
        } else if (textField.placeholder! == "City") {
            signInInfo!.address.city = textField.text!
        } else if (textField.placeholder! == "State") {
            signInInfo!.address.state = textField.text!
        } else if (textField.placeholder! == "Zip") {
            signInInfo!.address.zip = textField.text!
        }
    }
    @IBAction func textFieldDidBeginEditing(_ sender: RoundedTextField) {
        if phone.text == "" {
            phone.text = "+1"
        }
    }
    
    @IBAction func nextButtonPressedDown(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        if(checkFormatting() && checkTextFieldsFilled()) {
            performSegue(withIdentifier: "My Info To Year And Major", sender: self)
        }
    }

    @IBAction func nextButtonReleased(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    }

    @IBAction func unwindToMyInfo(segue:UIStoryboardSegue) {

    }

    func checkTextFieldsFilled() -> Bool {
        if (!firstName.isEmpty() &&
           !lastName.isEmpty() &&
           !birthdate.isEmpty() &&
           !phone.isEmpty() &&
           !email.isEmpty() &&
           !streetAddress.isEmpty() &&
           !city.isEmpty() &&
           !state.isEmpty() &&
           !zip.isEmpty()) {
            return true
        } else {
            let alert = UIAlertController(title: "Missing Information", message: "Please fill out ALL fields", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(Ok)
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    func checkFormatting() -> Bool {

        let DATE_REGEX = "^[0-9]{4}\\-[0-9]{2}\\-[0-9]{2}$"
        let birthdateTest = NSPredicate(format: "SELF MATCHES %@", DATE_REGEX)
        let birthdateCorrect =  birthdateTest.evaluate(with: birthdate.text ?? "")
        
        let PHONE_REGEX = "^\\+1[0-9]{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let phoneCorrect =  phoneTest.evaluate(with: phone.text ?? "")
        
        if (!birthdateCorrect && !phoneCorrect) {
            let alert = UIAlertController(title: "Incorrect Formatting", message: "Please enter your birthdate in the format YYYY-MM-DD, and your phone in the format +1XXXXXXXXXX", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(Ok)
            self.present(alert, animated: true, completion: nil)
            return false
        } else if (!birthdateCorrect) {
            let alert = UIAlertController(title: "Incorrect Formatting", message: "Please enter your birthdate in the format YYYY-MM-DD", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(Ok)
            self.present(alert, animated: true, completion: nil)
            return false
        } else if (!phoneCorrect) {
            let alert = UIAlertController(title: "Incorrect Formatting", message: "Please enter your phone in the format +1XXXXXXXXXX", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(Ok)
            self.present(alert, animated: true, completion: nil)
            return false
        } else {
            signInInfo?.other.birthdate = birthdate.text!
            signInInfo?.contact.phone = phone.text!
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "My Info To Year And Major" {
            let yearAndMajorViewController = segue.destination as! YearAndMajorViewController
            if sender != nil {
                yearAndMajorViewController.signInInfo = signInInfo
            }
        }
    }
}
