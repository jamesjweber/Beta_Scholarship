//
//  AccountInfoTableViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/14/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSCognitoIdentityProvider
import AWSS3
import GoogleSignIn

class AccountInfoTableViewController: UITableViewController {

    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var birthdate: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var major: UILabel!
    @IBOutlet weak var positions: UILabel!
    @IBOutlet weak var proboLevel: UILabel!
    @IBOutlet weak var brotherStatus: UILabel!
    @IBOutlet weak var pinNumber: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    var preloadedProfilePic: UIImage?
    var profilePicURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }

        if (preloadedProfilePic != nil) {
            profilePic.image = preloadedProfilePic
        }

        self.refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /* if let response = self.response  {
            return response.userAttributes!.count - 1
        } */
        return 9
    }

    func setLabels() {
        if let userAttributes = response?.userAttributes! {
            for userAttribute in userAttributes {
                if (userAttribute.name == "custom:house_positions") {
                    positions.text = userAttribute.value!
                } else if (userAttribute.name == "address") {
                    address.text = userAttribute.value!
                } else if (userAttribute.name == "birthdate") {
                    birthdate.text = userAttribute.value!
                } else if (userAttribute.name == "custom:year") {
                    year.text! = userAttribute.value!
                } else if (userAttribute.name == "custom:contact_email") {
                    email.text! = userAttribute.value!
                } else if (userAttribute.name == "given_name") {
                    firstName.text! = userAttribute.value!
                } else if (userAttribute.name == "custom:probo_level") {
                    proboLevel.text! = userAttribute.value!
                } else if (userAttribute.name == "custom:pin_number") {
                    pinNumber.text! = userAttribute.value!
                } else if (userAttribute.name == "custom:major") {
                    major.text! = userAttribute.value!
                } else if (userAttribute.name == "custom:profile_pic_url") {
                    profilePicURL = userAttribute.value!
                } else if (userAttribute.name == "phone_number") {
                    phone.text! = userAttribute.value!
                } else if (userAttribute.name == "family_name") {
                    lastName.text! = userAttribute.value!
                } else if (userAttribute.name == "custom:brother_status") {
                    brotherStatus.text! = userAttribute.value!
                } else if (userAttribute.name == "custom:pin_number") {
                    pinNumber.text! = userAttribute.value!
                }
            }
        }
    }

    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }

    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.profilePic.image = UIImage(data: data)
            }
        }
    }
    
    
    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                if let response = self.response {
                    self.setLabels()
                    if(self.profilePicURL != nil) {
                        if (self.profilePic.image == UIImage(named: "defaultProfilePicture")) {
                            let myURL: URL = URL(string: "\(self.profilePicURL!).PNG")!
                            self.downloadImage(url: myURL)
                        }
                    }
                } else {
                    print("ruh")
                }
            })
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToSettingsSegue" {
            let settingsViewController = segue.destination as! SettingsTableViewController
            if sender != nil {
                settingsViewController.profilePic = profilePic
            }
        }
    }

}
