//
//  TimerViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/14/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {

    @IBOutlet weak var timerText: UILabel!
    @IBOutlet weak var timerRing: MKRingProgressView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var startStudyingSubmitHoursButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startStudyingSubmitHoursPressed(_ sender: Any) {
        
    }
    
    @IBAction func pausePressed(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
