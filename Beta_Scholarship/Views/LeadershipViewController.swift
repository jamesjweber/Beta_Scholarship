//
//  YearAndMajorTableViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/24/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import DeviceKit

class LeadershipViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!

    struct HousePositionSections {
        var sectionName : String!
        var sectionPositions : [String]!
    }

    var checked = Set<IndexPath>()
    var userHousePositions:[String] = [String]()
    var signInInfo: signInInformation?
    var housePosArr = [HousePositionSections]()

    func setHousePositionSections() {
        housePosArr = [
            HousePositionSections(sectionName: "Misc. House Positions",
                    sectionPositions: ["President",
                                       "Chapter Counselor",
                                       "IFC Representative",
                                       "Technology Chair",
                                       "Wellness Chair",
                                       "Wellness Committee",
                                       "BMOC Chair",
                                       "BMOC Member"]),

            HousePositionSections(sectionName: "Programming",
                    sectionPositions: ["VP of Programming",
                                       "Programming Committee Member",
                                       "Social Chair",
                                       "Social Committee Member",
                                       "Philanthropy Chair",
                                       "Community Service Chair",
                                       "Intramural Chair"]),

            HousePositionSections(sectionName: "Brotherhood",
                    sectionPositions: ["VP of Brotherhood",
                                       "Brotherhood Chair",
                                       "Brotherhood Committee Member",
                                       "Kai Chair",
                                       "Kai Committee",
                                       "Scholarship Chair",
                                       "Scholarship Committee Member",
                                       "Ritual Chair"]),

            HousePositionSections(sectionName: "Education",
                    sectionPositions: ["VP of Education",
                                       "Education Chair",
                                       "Education Committee Member",
                                       "Active Member Education"]),

            HousePositionSections(sectionName: "Recruitment",
                    sectionPositions: ["VP of Recruitment",
                                       "Recruitment Committee Member"]),

            HousePositionSections(sectionName: "Risk Management",
                    sectionPositions: ["VP of Risk",
                                       "Risk Committee Member",
                                       "House Manager"]),

            HousePositionSections(sectionName: "Finance",
                    sectionPositions: ["VP of Finance",
                                       "Kitchen Manager"]),

            HousePositionSections(sectionName: "Communication",
                    sectionPositions: ["VP of Communication",
                                       "Social Media Chair"])
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let signIn = signInInfo {
            print("signIn.beta.proboLevel: \(signIn.beta.proboLevel)")
        }

        tableView.delegate = self
        tableView.dataSource = self
        configureButton(button: nextButton, view: self)
        setHousePositionSections() 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return housePosArr.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return housePosArr[section].sectionPositions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HousePositions", for: indexPath)
        cell.textLabel?.text = housePosArr[indexPath.section].sectionPositions[indexPath.row]
        cell.backgroundColor = UIColor.white

        if (checked.contains(indexPath)) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return housePosArr[section].sectionName
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if self.checked.contains(indexPath) {
            self.checked.remove(indexPath)
            for x in 0..<self.userHousePositions.count {
                if self.userHousePositions[x] == (tableView.cellForRow(at: indexPath)?.textLabel?.text)! {
                    self.userHousePositions.remove(at: x)
                }
            }
        } else {
            self.checked.insert(indexPath)
            self.userHousePositions.append((tableView.cellForRow(at: indexPath)?.textLabel?.text!)!)
        }

        tableView.reloadRows(at:[indexPath], with:.fade)
    }

    /* func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        let section = indexPath.section
        let numberOfRows = tableView.numberOfRows(inSection: section)
        for row in 0..<numberOfRows {
            if let cell = tableView.cellForRow(at: NSIndexPath(row: row, section: section) as IndexPath) as UITableViewCell? {
                if ( row == indexPath.row ) { cell.accessoryType = .checkmark }
                self.userHousePositions.append((cell.textLabel?.text)!)
                for x in 0..<self.userHousePositions.count {
                    if self.userHousePositions[x] == (cell.textLabel?.text)! {
                        self.userHousePositions.remove(at: x)
                    }
                }
            }
        }

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            for x in 0..<self.userHousePositions.count {
                if self.userHousePositions[x] == (cell.textLabel?.text)! {
                    self.userHousePositions.remove(at: x)
                }
            }
        }
    } */

    func changeTextForSmallDevices() {
        let modelName = Device()
        print("model: " + String(modelName.description))
        if (modelName.description == "iPhone 5s" || modelName.description == "iPhone SE" || modelName.description == "Simulator (iPhone 5s)") {
            bottomLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            bottomLabel.sizeToFit()
        }
    }
    
    @IBAction func unwindToLeadership(segue:UIStoryboardSegue) {
        
    }


    @IBAction func nextButtonPressed(_ sender: UIButton) {

        if userHousePositions.isEmpty {
            signInInfo?.beta.housePositions = "None"
        } else {
            let housePositionsString = userHousePositions.joined(separator: ", ")
            signInInfo?.beta.housePositions = housePositionsString
        }

        performSegue(withIdentifier: "House Positions To App Information", sender: self)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "House Positions To App Information" {
            let appInfoViewController = segue.destination as! AppInfoViewController
            if sender != nil {
                appInfoViewController.signInInfo = signInInfo
            }
        }
    }

}
