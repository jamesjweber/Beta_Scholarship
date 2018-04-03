//
//  ScholarshipCommitteeTableViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/16/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ScholarshipCommitteeTableViewController: UITableViewController {

    @IBOutlet weak var segmentedController: UISegmentedControl!
    var selectedName: String?
    
    var probo1 = ["Diego Cabrales",
    "Jonathon Dean",
    "Andrew Read",
    "Shea Solmos",
    "Brastone Ngoma",
    "Grant Vasquez",
    "Preston Casper"]
    
    var probo2 = ["Sam Bondi",
    "Josh Meiners",
    "Dylan Stants",
    "Corey Wogenstahl",
    "Bryce Wooldridge",
    "Grady Young"]
    
    var probo3 = ["Harrison Yardley",
    "Alec Chapman",
    "Tim Dotson",
    "Alex Miller",
    "Colin O'Connor"]


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var returnValue = 0

        switch (segmentedController.selectedSegmentIndex) {
        case 0:
            returnValue = probo1.count
            break
        case 1:
            returnValue = probo2.count
            break
        case 2:
            returnValue = probo3.count
            break
        default:
            break
        }

        return returnValue
    }

    @IBAction func segmentedControlActionChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "proboUserCell", for: indexPath)

        switch (segmentedController.selectedSegmentIndex) {
        case 0:
            cell.textLabel?.text = probo1[indexPath.row]
            break
        case 1:
            cell.textLabel?.text = probo2[indexPath.row]
            break
        case 2:
            cell.textLabel?.text = probo3[indexPath.row]
            break
        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (segmentedController.selectedSegmentIndex) {
        case 0:
            selectedName = probo1[indexPath.row]
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            performSegue(withIdentifier: "User Hours To Details", sender: self)
            break
        case 1:
            selectedName = probo2[indexPath.row]
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            performSegue(withIdentifier: "User Hours To Details", sender: self)
            break
        case 2:
            selectedName = probo3[indexPath.row]
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            performSegue(withIdentifier: "User Hours To Details", sender: self)
            break
        default:
            break
        }
        
    }

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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "User Hours To Details" {
            let detailsViewController = segue.destination as! DetailsViewController
            if sender != nil {
                detailsViewController.name = selectedName
            }
        }
    }
}
