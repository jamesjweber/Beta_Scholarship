//
//  MyInfoViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/23/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit

class MyInfoViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureButton(button: backButton, view: self)
        configureButton(button: nextButton, view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func backButtonPressedDown(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    @IBAction func backButtonReleased(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    }
    
    @IBAction func nextButtonPressedDown(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    @IBAction func nextButtonReleased(_ sender: UIButton) {
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    }
    
    @IBAction func unwindToMyInfo(segue:UIStoryboardSegue) {
        
    }
}
