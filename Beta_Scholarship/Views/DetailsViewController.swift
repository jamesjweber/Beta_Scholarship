//
//  DetailsViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/17/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSCognitoIdentityProvider

class DetailsViewController: UIViewController {
    @IBOutlet weak var hoursTableView: MyHoursTableView!
    
    var credentialsProvider: AWSCognitoCredentialsProvider?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var userInfo: userInformation?
    var userHours = [studyHours]()
    let cache = NSCache<NSString, userInformation>()
    var pagniatedOutput: AWSDynamoDBPaginatedOutput?
    var tableRows:Array<studyHours>?
    var tableSection:Array<Array<studyHours>?>?
    var doneLoading = false
    var lock:NSLock?
    var lastEvaluatedKey:[String : AWSDynamoDBAttributeValue]!
    var needsToRefresh = false
    var maxWeek:Int = 1
    var weekTotal = [Double]()
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hoursTableView.dataSource = self
        
        tableRows = []
        tableSection = []
        lock = NSLock()
        
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.needsToRefresh {
            self.refreshList(true)
            self.needsToRefresh = false
        }
        
    }
    
}

extension DetailsViewController: UITableViewDataSource {
    
    func refresh() {
        
        print("REEFRESHING")
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "NameOfUser"
        queryExpression.keyConditionExpression = "NameOfUser = :name AND Week <= :week" // test
        queryExpression.expressionAttributeValues = [":name" : self.name as Any, ":week" : 16]
        
        dynamoDBObjectMapper.query(studyHours.self, expression: queryExpression).continueWith(block: { (task: AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
            if let error = task.error as NSError? {
                print("Error: \(error)")

                let alertController = UIAlertController(title: "Failed to query a test table.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                if let result = task.result {//(task.result != nil) {
                    self.pagniatedOutput = result
                }
                print("DAWG")
                self.tableRows?.removeAll(keepingCapacity: true)

                if self.pagniatedOutput != nil {

                    var tempTotalHours: Double = 0

                    for item in self.pagniatedOutput!.items as! [studyHours] {

                        if item.Week!.intValue > self.maxWeek {

                            self.tableSection?.append(self.tableRows)
                            self.weekTotal.append(tempTotalHours)
                            tempTotalHours = 0

                            print("new tableSection.count: \(self.tableSection?.count)")

                            let diff = item.Week!.intValue - self.maxWeek
                            if diff > 1 {
                                for x in 1..<diff {
                                    self.tableSection?.append([])
                                    self.weekTotal.append(0)
                                }
                            }

                            self.maxWeek = item.Week!.intValue

                            self.tableRows = []
                        }

                        self.tableRows?.append(item)
                        tempTotalHours += item.Hours!.doubleValue
                    }
                    self.tableSection?.append(self.tableRows)
                    self.weekTotal.append(tempTotalHours)
                }

                self.doneLoading = true

                DispatchQueue.main.async {
                    self.hoursTableView.reloadData()
                }
            }
            return nil
        })
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if var myTableRows = self.tableSection {
                let section = maxWeek - indexPath.section - 1
                let row = indexPath.row - 1
                let item = myTableRows[section]![row]
                self.deleteTableRow(item)
                myTableRows[section]!.remove(at: row)
                self.tableSection = myTableRows
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func deleteTableRow(_ row: studyHours) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.remove(row).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let error = task.error as NSError? {
                print("Error: \(error)")
                
                let alertController = UIAlertController(title: "Failed to delete a row.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            return nil
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        print("the max week: \(maxWeek)")
        return maxWeek
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Week \(maxWeek - section)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let tableSection = tableSection {
            let tableSectionCount = tableSection.count
            if tableSectionCount >= (section + 1) {
                return (tableSection[maxWeek - section - 1]!.count + 1) // For static total cell
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = maxWeek - indexPath.section - 1
        
        if indexPath.row == 0 {
            let staticCell = tableView.dequeueReusableCell(withIdentifier: "Week Total", for: indexPath)
            
            staticCell.textLabel?.text = "Total: \(weekTotal[section]) Hour\(weekTotal[section] == 1 ? "" : "s")"
            
            return staticCell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            // Configure the cell...
            
            print("self.tableSection.count: \(self.tableSection?.count)")
            
            if let myTableSections = self.tableSection {
                let row = indexPath.row - 1
                
                let item = myTableSections[section]![row]
                
                var dow = String()
                
                if let dowCase = getDayOfWeek(today: String(item.Date_And_Time!.prefix(8))) {
                    switch (dowCase) {
                    case 1:
                        dow = "Sunday,"
                        break
                    case 2:
                        dow = "Monday,"
                        break
                    case 3:
                        dow = "Tuesday,"
                        break
                    case 4:
                        dow = "Wednesday,"
                        break
                    case 5:
                        dow = "Thursday,"
                        break
                    case 6:
                        dow = "Friday,"
                        break
                    case 7:
                        dow = "Saturday,"
                        break
                    default:
                        dow = ""
                    }
                }
                
                cell.textLabel?.text = "\(dow) \(item.Hours!) Hour\(item.Hours! == 1 ? "" : "s")"
                
                if let myDetailTextLabel = cell.detailTextLabel {
                    myDetailTextLabel.text = "\(item.Location!)"
                }
                
                if indexPath.row == myTableSections[section]!.count && !self.doneLoading {
                    self.refreshList(false)
                }
            }
            
            return cell
        }
    }
    
    func refreshList(_ startFromBeginning: Bool)  {
        if (self.lock?.try() != nil) {
            if startFromBeginning {
                self.lastEvaluatedKey = nil;
                self.doneLoading = false
            }
            
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            let queryExpression = AWSDynamoDBScanExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 20
            dynamoDBObjectMapper.scan(studyHours.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
                
                if self.lastEvaluatedKey == nil {
                    self.tableRows?.removeAll(keepingCapacity: true)
                }
                
                if let paginatedOutput = task.result {
                    for item in paginatedOutput.items as! [studyHours] {
                        self.tableRows?.append(item)
                        print("item:: \(item.Class)")
                        print("self.tableRows?.count: \(self.tableRows?.count)")
                    }
                    
                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                    if paginatedOutput.lastEvaluatedKey == nil {
                        self.doneLoading = true
                    }
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.hoursTableView.reloadData()
                
                if let error = task.error as NSError? {
                    print("Error: \(error)")
                }
                
                return nil
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
    }
    
    /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "Study Hours Details Segue" {
            let detailViewController = segue.destination as! StudyHoursDetailViewController
            if sender != nil {
                if sender is UIAlertController {
                    detailViewController.viewType = .insert
                } else if sender is UITableViewCell {
                    let cell = sender as! UITableViewCell
                    detailViewController.viewType = .update
                    
                    let indexPath = self.hoursTableView.indexPath(for: cell)
                    
                    let row = indexPath!.row - 1
                    let section = maxWeek - indexPath!.section - 1
                    
                    let tableRow = self.tableSection?[section]![row]
                    detailViewController.tableRow = tableRow
                }
            }
        }
    } */
    
    func getDayOfWeek(today:String)->Int? {
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        if let todayDate = formatter.date(from: today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let myComponents = myCalendar.components(.weekday, from: todayDate)
            let weekDay = myComponents.weekday
            return weekDay
        } else {
            return nil
        }
    }
    
    /* @IBAction func unwindToMainTableViewControllerFromSearchViewController(_ unwindSegue:UIStoryboardSegue) {
        self.tableRows?.removeAll(keepingCapacity: true)
        
        self.doneLoading = true
        
        DispatchQueue.main.async {
            self.hoursTableView.reloadData()
        }
    } */
    
}


