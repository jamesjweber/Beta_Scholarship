//
//  SettingsTableViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/7/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSCognitoIdentityProvider
import AWSS3
import GoogleSignIn

class SettingsTableViewController: UITableViewController, GIDSignInUIDelegate {

    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    var profilePicURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // S3 Intializations
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1, identityPoolId:"us-east-1:bb023064-cbc1-40da-8cfc-84cc04d5485f")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        // Other AWS Stuff
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        refresh()
        refresh2()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /* override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    } */

    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
            })
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print(indexPath.section)
        print(indexPath.row)

        if indexPath.section == 1 && indexPath.row == 0 {
            print("signing out")

            // Sign Out
            let alert = UIAlertController(title: nil, message: "Are you sure you want to to log out?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Log Out", comment: "Default action"), style: .destructive, handler: { (action) -> Void in
                // Sign Out
                self.user?.signOut()
                self.title = nil
                self.response = nil
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        /*
        if (indexPath.section == 1 && indexPath.row == 1) {
            if (GIDSignIn.sharedInstance().currentUser == nil) {
                GIDSignIn.sharedInstance().signIn()
            }
        }*/

        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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


    func refresh2() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                if let response = self.response {
                    self.setLabels()
                    if(self.profilePicURL != nil) {
                        if (self.profilePic.image == UIImage(named: "defaultProfilePicture")) {
                            let myURL: URL = URL(string: "\(self.profilePicURL!)")!
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

    func setLabels() {
        if let userAttributes = response?.userAttributes! {
            for userAttribute in userAttributes {
                if (userAttribute.name == "given_name") {
                    firstName.text! = userAttribute.value!
                } else if (userAttribute.name == "custom:profile_pic_url") {
                    profilePicURL = userAttribute.value!
                } else if (userAttribute.name == "family_name") {
                    lastName.text! = userAttribute.value!
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Settings To Account Info" {
            let accountInfoViewController = segue.destination as! AccountInfoTableViewController
            if sender != nil {
                accountInfoViewController.preloadedProfilePic = profilePic.image
            }
        }
    }
    
    @IBAction func unwindToSettings(segue:UIStoryboardSegue) {
        
    }

}
