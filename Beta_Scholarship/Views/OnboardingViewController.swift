//
//  OnboardingViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/13/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import CoreLocation

class OnboardingViewController: UIViewController {

    @IBOutlet weak var allowLocationButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!

    var allowLocation: Bool = false

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureButton(button: allowLocationButton, view: self)
        configureButton(button: continueButton, view: self)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userAllowingLocation(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        continueButton.isEnabled = true
    }
    
    @IBAction func doneOnboarding(sender: UIButton) {

        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                let alertController = UIAlertController(title: "Location Services Required",
                        message: "Location services permissions were not authorized. Please enable it in Settings to continue.",
                        preferredStyle: .alert)

                let settingsAction = UIAlertAction(title: "Settings", style: .cancel) { (alertAction) in

                    // THIS IS WHERE THE MAGIC HAPPENS!!!!
                    if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.open(appSettings, completionHandler: nil)
                    }
                }
                alertController.addAction(settingsAction)

                self.present(alertController, animated: true, completion: nil)
            case .authorizedAlways, .authorizedWhenInUse:
                //set the default
                print("GUCCI")
                Settings.groupDefaults().set(true, forKey: onboardingKey)
                //now load the main storyboard
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.launchStoryboard(storyboard: .Main)

                return
            }
        }
    }


}
