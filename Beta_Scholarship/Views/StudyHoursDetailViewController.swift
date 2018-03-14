//
//  StudyHoursDetailViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/13/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import AWSDynamoDB

class StudyHoursDetailViewController: UIViewController {

    enum DDBDetailViewType {
        case unknown
        case insert
        case update
    }
    
    @IBOutlet weak var rangeKeyTextField: UILabel!
    @IBOutlet weak var attribute1TextField: UILabel!
    @IBOutlet weak var attribute2TextField: UILabel!
    
    var viewType:DDBDetailViewType = DDBDetailViewType.unknown
    var tableRow:studyHours?
    
    var dataChanged = false
    
    func getTableRow() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        //tableRow?.UserId --> (tableRow?.UserId)!
        dynamoDBObjectMapper .load(studyHours.self, hashKey: (tableRow?.Date_And_Time)!, rangeKey: tableRow?.NameOfUser) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
                let alertController = UIAlertController(title: "Failed to get item from table.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else if let tableRow = task.result as? studyHours {
                self.title = self.getTitle(tableRow.Date_And_Time!)
                self.rangeKeyTextField.text = "\(tableRow.Hours!) Hour\(tableRow.Hours == 1 ? "" : "s")"
                self.attribute1TextField.text = tableRow.Class
                self.attribute2TextField.text = tableRow.Location
            }
            
            return nil
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.getTableRow()
    }

    func getTitle(_ date_and_time: String) -> String {
        let date = date_and_time.prefix(8)

        var dow = String()
        if let dowCase = getDayOfWeek(today: String(date)) {
            switch (dowCase) {
            case 1:
                dow = "Sunday, "
                break
            case 2:
                dow = "Monday, "
                break
            case 3:
                dow = "Tuesday, "
                break
            case 4:
                dow = "Wednesday, "
                break
            case 5:
                dow = "Thursday, "
                break
            case 6:
                dow = "Friday, "
                break
            case 7:
                dow = "Saturday, "
                break
            default:
                dow = "Details"
            }
        }

        var month = String()
        if let monthCase = getMonth(today: String(date)) {
            switch (monthCase) {
            case 1:
                month = "Jan "
                break
            case 2:
                month = "Feb "
                break
            case 3:
                month = "Mar "
                break
            case 4:
                month = "Apr "
                break
            case 5:
                month = "May "
                break
            case 6:
                month = "Jun "
                break
            case 7:
                month = "Jul "
                break
            case 8:
                month = "Aug "
                break
            case 9:
                month = "Sep "
                break
            case 10:
                month = "Oct "
                break
            case 11:
                month = "Nov "
                break
            case 12:
                month = "Dec "
                break
            default:
                month = ""
            }
        }

        var day = String()

        if let dayCase = getDay(today: String(date)) {
            switch (dayCase) {
            case 1:
                day = "1st"
                break
            case 2:
                day = "2nd"
                break
            case 3:
                day = "3rd"
                break
            case 4:
                day = "4th"
                break
            case 5:
                day = "5th"
                break
            case 6:
                day = "6th"
                break
            case 7:
                day = "7th"
                break
            case 8:
                day = "8th"
                break
            case 9:
                day = "9th"
                break
            case 10:
                day = "10th"
                break
            case 11:
                day = "11th"
                break
            case 12:
                day = "12th"
                break
            case 13:
                day = "13th"
                break
            case 14:
                day = "14th"
                break
            case 15:
                day = "15th"
                break
            case 16:
                day = "16th"
                break
            case 17:
                day = "17th"
                break
            case 18:
                day = "18th"
                break
            case 19:
                day = "19th"
                break
            case 20:
                day = "20th"
                break
            case 21:
                day = "21st"
                break
            case 22:
                day = "22nd"
                break
            case 23:
                day = "23rd"
                break
            case 24:
                day = "24th"
                break
            case 25:
                day = "25th"
                break
            case 26:
                day = "26th"
                break
            case 27:
                day = "27th"
                break
            case 28:
                day = "28th"
                break
            case 29:
                day = "29th"
                break
            case 30:
                day = "30th"
                break
            case 24:
                day = "31st"
                break
            default:
                day = ""
            }
        }

        return "\(dow)\(month)\(day)"
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

    func getMonth(today:String)->Int? {

        let formatter  = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        if let todayDate = formatter.date(from: today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let myComponents = myCalendar.components(.month, from: todayDate)
            let month = myComponents.month
            return month
        } else {
            return nil
        }
    }

    func getDay(today:String)->Int? {

        let formatter  = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        if let todayDate = formatter.date(from: today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let myComponents = myCalendar.components(.day, from: todayDate)
            let day = myComponents.day
            return day
        } else {
            return nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.dataChanged) {
            let c = self.navigationController?.viewControllers.count
            let mainTableViewController = self.navigationController?.viewControllers [c! - 1] as! MyHoursViewController
            mainTableViewController.needsToRefresh = true
        }
    }
    

}
