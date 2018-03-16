//
//  HouseStatusViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/24/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import DeviceKit

class HouseStatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var pinNumber: RoundedTextField!
    
    let BrotherStatus:[String] = ["Brother","Pledge","Neophyte"]
    var houseStatus = String()
    var signInInfo: signInInformation?
    var brotherStatusSelected = false
    var isNotBrother = false
    var pinSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        //tableView.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        if let signIn = signInInfo {
            print("signIn.school.major: \(signIn.school.major)")
        }

        tableView.delegate = self
        tableView.dataSource = self
        configureButton(button: nextButton, view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return BrotherStatus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "HouseStatus", for: indexPath)

        cell.textLabel?.text = BrotherStatus[indexPath.row]
        cell.backgroundColor = UIColor.white
        return cell
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            houseStatus = (cell.textLabel?.text)!
            signInInfo?.beta.brotherStatus = (cell.textLabel?.text)!
            brotherStatusSelected = true
            if((cell.textLabel?.text)! == "Brother") {
                pinNumber.isEnabled = true
                isNotBrother = false
            } else {
                isNotBrother = true
                pinNumber.isEnabled = false
            }
        }
    }
    @IBAction func pinNumberChanged(_ sender: RoundedTextField) {
        signInInfo?.beta.pin = pinNumber.text!
        
        if (!pinNumber.isEmpty()) {
            pinSelected = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }

    func changeTextForSmallDevices() {
        let modelName = Device()
        print("model: " + String(modelName.description))
        if (modelName.description == "iPhone 5s" || modelName.description == "iPhone SE" || modelName.description == "Simulator (iPhone 5s)") {
            bottomLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            bottomLabel.sizeToFit()
        }
    }

    @IBAction func unwindToHouseStatus(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if ((!pinSelected && !isNotBrother) && !brotherStatusSelected) {
            let alert = UIAlertController(title: "Missing Information", message: "Please fill out ALL fields", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(Ok)
            self.present(alert, animated: true, completion: nil)
        } else if (!pinSelected && !isNotBrother) {
            let alert = UIAlertController(title: "Missing Information", message: "Please fill out the 'PIN' field", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(Ok)
            self.present(alert, animated: true, completion: nil)
        } else if (!brotherStatusSelected) {
            let alert = UIAlertController(title: "Missing Information", message: "Please select your house status", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(Ok)
            self.present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "Brother Status To Probo Level", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Brother Status To Probo Level" {
            let proboLevelViewController = segue.destination as! ProboLevelViewController
            if sender != nil {
                proboLevelViewController.signInInfo = signInInfo
            }
        }
    }

}
