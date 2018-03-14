//
//  MyHoursViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/12/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSCognitoIdentityProvider

class MyHoursViewController: UIViewController {

    @IBOutlet weak var statsCollectionView: UICollectionView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var hoursTableView: UITableView!

    var credentialsProvider: AWSCognitoCredentialsProvider?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var name: String!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        statsCollectionView.delegate = self
        statsCollectionView.dataSource = self
        scrollView.delegate = self
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MyHoursViewController: UITableViewDataSource {

    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                if let response = self.response {
                    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                    //
                    // This section will get the user's info and save it in a local cache to save
                    // loading time. The user's info requires that self.response be fully loaded from
                    // task.result before it can get user info.
                    //
                    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                    if let cachedUserInfo = self.cache.object(forKey: "CachedObject") {
                        // use the cached version
                        print("getting cached userinfo")
                        self.userInfo = cachedUserInfo
                    } else {
                        // create it from scratch then store in the cache
                        print("cacheing")
                        self.userInfo = userInformation(self.response!)
                        self.cache.setObject(self.userInfo!, forKey: "CachedObject")
                    }

                    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                    //
                    // This section queries our DynamoDB table, which contains all of the hours for
                    // the users. It will specifically query the hours for the given user for this
                    // semester. It wil automatically update, so if I manually change someone's
                    // hours it will remove the previous hours, and will add the correct hours to
                    // their hours.
                    //
                    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

                    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
                    let queryExpression = AWSDynamoDBQueryExpression()
                    queryExpression.indexName = "NameOfUser"
                    queryExpression.keyConditionExpression = "NameOfUser = :name AND Week <= :week" // test
                    queryExpression.expressionAttributeValues = [":name" : self.userInfo?.fullName! as Any, ":week" : 16]

                    dynamoDBObjectMapper.query(studyHours.self, expression: queryExpression).continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
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

                            if self.pagniatedOutput != nil{
                                
                                var tempTotalHours:Double = 0
                                
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
                        //self.activityIndicator.stopAnimating()
                        return nil
                    })

                } else {
                    print("Error getting response")
                }
            })
            return nil
        }
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    }

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

    @IBAction func unwindToMainTableViewControllerFromSearchViewController(_ unwindSegue:UIStoryboardSegue) {
        self.tableRows?.removeAll(keepingCapacity: true)

        self.doneLoading = true

        DispatchQueue.main.async {
            self.hoursTableView.reloadData()
        }
    }

}

extension MyHoursViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myDataCell", for: indexPath) as! SectionCollectionViewCell
        let section = sections[indexPath.row]

        cell.titleLabel.text = section["title"]
        cell.iconImageView.image = UIImage(named: section["image"]!)
        cell.background.backgroundColor = Colors().color(named: section["color"]!)

        cell.layer.transform = animateCell(cellFrame: cell.frame)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.row]
        
        self.performSegue(withIdentifier: "Location Trends To Modal View", sender: nil)
    }

}

extension MyHoursViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            for cell in collectionView.visibleCells as! [SectionCollectionViewCell] {
                let indexPath = collectionView.indexPath(for: cell)!
                let attributes = collectionView.layoutAttributesForItem(at: indexPath)!
                let cellFrame = collectionView.convert(attributes.frame, to: view)

                let translationX = cellFrame.origin.x / 5
                cell.fauxProgressBars.transform = CGAffineTransform(translationX: translationX, y: 0)

                cell.layer.transform = animateCell(cellFrame: cellFrame)
            }
        }
    }

    func animateCell(cellFrame: CGRect) -> CATransform3D {
        let angleFromX = Double((-cellFrame.origin.x) / 20)
        let angle = CGFloat((angleFromX * Double.pi) / 180.0)
        var transform = CATransform3DIdentity
        transform.m34 = -1.0/500
        let rotation = CATransform3DRotate(transform, angle, 0, 1, 0)
        var scaleFromX = (1000 - (cellFrame.origin.x - 200)) / 1000
        let scaleMax: CGFloat = 1.0
        let scaleMin: CGFloat = 0.6
        if scaleFromX > scaleMax {
            scaleFromX = scaleMax
        }
        if scaleFromX < scaleMin {
            scaleFromX = scaleMin
        }
        let scale = CATransform3DScale(CATransform3DIdentity, scaleFromX, scaleFromX, 1)
        
        return CATransform3DConcat(rotation, scale)
    }
   
}
