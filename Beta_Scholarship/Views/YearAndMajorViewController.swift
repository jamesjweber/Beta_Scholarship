//
//  YearAndMajorTableViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/24/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import DeviceKit

class YearAndMajorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var major: RoundedTextField!
    
    let YearInSchool:[String] = ["Freshman","Sophomore","Junior","Senior","Other"]
    var year = String()
    var signInInfo: signInInformation?
    
    var yearSelected = false
    var majorSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        configureButton(button: nextButton, view: self)

        if let name = signInInfo!.name.first {
            print("first name: \(name)")
        } else {
            print("not gucci")
        }
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
        return YearInSchool.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SchoolYear", for: indexPath)

        cell.textLabel?.text = YearInSchool[indexPath.row]
        cell.backgroundColor = UIColor.white
        return cell
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            year = (cell.textLabel?.text)!
            signInInfo?.school.year = cell.textLabel?.text!
            yearSelected = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    @IBAction func majorTextFieldDidChange(_ sender: RoundedTextField) {
        signInInfo?.school.major = major.text!
        if (!major.isEmpty()) {
            majorSelected = true
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
    
    @IBAction func unwindToYearAndMajor(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func nextButtonTouched(_ sender: UIButton) {
//        if (!majorSelected && !yearSelected) {
//            let alert = UIAlertController(title: "Missing Information", message: "Please fill out ALL fields", preferredStyle: .alert)
//            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
//            alert.addAction(Ok)
//            self.present(alert, animated: true, completion: nil)
//        } else if (!yearSelected) {
//            let alert = UIAlertController(title: "Missing Information", message: "Please select your year in school", preferredStyle: .alert)
//            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
//            alert.addAction(Ok)
//            self.present(alert, animated: true, completion: nil)
//        } else if (!majorSelected) {
//            let alert = UIAlertController(title: "Missing Information", message: "Please fill out the 'Major' field", preferredStyle: .alert)
//            let Ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
//            alert.addAction(Ok)
//            self.present(alert, animated: true, completion: nil)
//        } else {
        performSegue(withIdentifier: "Year And Major To Brother Status", sender: self)
//        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Year And Major To Brother Status" {
            let brotherStatusViewController = segue.destination as! HouseStatusViewController
            if sender != nil {
                brotherStatusViewController.signInInfo = signInInfo
            }
        }
    }
}
















