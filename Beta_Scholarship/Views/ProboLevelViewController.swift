//
//  YearAndMajorTableViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/24/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import DeviceKit

class ProboLevelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    
    let ProboLevel:[String] = ["Not On Probo (GPA ≥2.85)","Probo 1 (2.85 > GPA ≥ 2.5)","Probo 2 (2.5 > GPA ≥ 2.0)","Probo 3 (2.0 > GPA)"]
    
    var brotherProboLevel = String()
    var signInInfo: signInInformation?
    var proboLevelSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let signIn = signInInfo {
            print("signIn.beta.pin: \(signIn.beta.pin)")
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
        return ProboLevel.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ProboLevels", for: indexPath)

        cell.textLabel?.text = ProboLevel[indexPath.row]
        cell.backgroundColor = UIColor.white
        return cell
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            brotherProboLevel = (cell.textLabel?.text)!
            if brotherProboLevel == "Not On Probo (GPA ≥2.85)" {
                signInInfo?.beta.proboLevel = "0"
            } else if brotherProboLevel == "Probo 1 (2.85 > GPA ≥ 2.5)" {
                signInInfo?.beta.proboLevel = "1"
            } else if brotherProboLevel == "Probo 2 (2.5 > GPA ≥ 2.0)" {
                signInInfo?.beta.proboLevel = "2"
            } else if brotherProboLevel == "Probo 3 (2.0 > GPA)" {
                signInInfo?.beta.proboLevel = "3"
            }
            
            proboLevelSelected = true
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
    
    @IBAction func unwindToProboLevel(segue:UIStoryboardSegue) {
        
    }

    @IBAction func nextButtonPressed(_ sender: UIButton) {

        if (!proboLevelSelected) {
            let alert = UIAlertController(title: "Missing Information", message: "Please select your current probation level", preferredStyle: .alert)
            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(Ok)
            self.present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "Probo Level To House Positions", sender: self)
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Probo Level To House Positions" {
            let housePositionsViewController = segue.destination as! LeadershipViewController
            if sender != nil {
                housePositionsViewController.signInInfo = signInInfo
            }
        }
    }
    
}
