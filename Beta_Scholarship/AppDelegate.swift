//
//  AppDelegate.swift
//  Beta_Scholarship
//
//  Created by James Weber on 1/4/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import CoreData
import AWSCognitoIdentityProvider
import AWSPinpoint
import AWSS3
import IQKeyboardManagerSwift
import GooglePlaces
import GoogleMaps
import Google
import GoogleSignIn

let onboardingKey = "onboardingShown"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var signInViewController: SignInViewController?
    //var mfaViewController: MFAViewController?
    var navigationController: UINavigationController?
    var storyboard: UIStoryboard?
    var rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>?
    let defaults = UserDefaults.standard
    var pinpoint: AWSPinpoint?

    enum StoryboardName : String {
        case Main = "Main"
        case Onboarding = "Onboarding"
    }


    func applicationDidFinishLaunching(_ application: UIApplication) {
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
    }

    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }

    func launchStoryboard(storyboard: StoryboardName) {
        //UIApplication.shared.setStatusBarHidden(true, with: .slide)
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        let controller = storyboard.instantiateInitialViewController()
        self.window?.rootViewController = controller
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "119748911166-vdrm2q4u9drusd6gg2me891li5tf4pfp.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self

        application.applicationIconBadgeNumber = 0

        // Initialize Pinpoint
        pinpoint = AWSPinpoint(configuration: AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions))

        // Warn user if configuration not updated
        if (CognitoIdentityUserPoolId == "YOUR_USER_POOL_ID") {
            let alertController = UIAlertController(title: "Invalid Configuration",
                    message: "Please configure user pool constants in Constants.swift file.",
                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)

            self.window?.rootViewController!.present(alertController, animated: true, completion:  nil)
        }

        // setup logging
        AWSDDLog.sharedInstance.logLevel = .verbose
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)

        // setup service configuration
        let serviceConfiguration = AWSServiceConfiguration(region: CognitoIdentityUserPoolRegion, credentialsProvider: nil)

        // create pool configuration
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: CognitoIdentityUserPoolAppClientId,
                clientSecret: CognitoIdentityUserPoolAppClientSecret,
                poolId: CognitoIdentityUserPoolId)

        // initialize user pool client
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: AWSCognitoUserPoolsSignInProviderKey)

        // fetch the user pool client we initialized in above step
        let pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.storyboard = UIStoryboard(name: "Main", bundle: nil)
        pool.delegate = self

        // Smart Keyboards
        IQKeyboardManager.sharedManager().enable = true

        // Add Google Maps and Places Services
        GMSPlacesClient.provideAPIKey("AIzaSyDiDa0xyWG2_rkrMQAPbc3kIM4r_CP1XDc")
        GMSServices.provideAPIKey("AIzaSyDiDa0xyWG2_rkrMQAPbc3kIM4r_CP1XDc")

        
        print("b4")
        Settings.registerDefaults()
        print("aftr")

        let onboardingOccured = Settings.groupDefaults().bool(forKey: onboardingKey)

        if(!onboardingOccured) {
            launchStoryboard(storyboard: StoryboardName.Onboarding)
        } else {
            launchStoryboard(storyboard: StoryboardName.Main)
        }

        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()

        return true
    }


    // Handle remote notification registration.
    func application(application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//send this device token to server
    }

//Called if unable to register for APNS.
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {

        print(error)

    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {

        print("Recieved: \(userInfo)")
        //Parsing userinfo:
        /* var temp : Dictionary = userInfo as? Dictionary
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
        {
            var alertMsg = info["alert"] as! String
            var alert: UIAlertView!
            alert = UIAlertView(title: "", message: alertMsg, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } */
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            // [START_EXCLUDE silent]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
            // [END_EXCLUDE]
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            // [START_EXCLUDE]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: nil,
                userInfo: ["statusText": "Signed in user:\n\(fullName)"])
            // [END_EXCLUDE]
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // [START_EXCLUDE]
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil,
            userInfo: ["statusText": "User has disconnected."])
        // [END_EXCLUDE]
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        defaults.set(CACurrentMediaTime(), forKey: "segueTime")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        defaults.set(CACurrentMediaTime(), forKey: "segueTime")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
        defaults.set(CACurrentMediaTime(), forKey: "segueTime")
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Beta_Scholarship")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

// MARK:- AWSCognitoIdentityInteractiveAuthenticationDelegate protocol delegate

extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {

    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        if (self.navigationController == nil) {
            print("\n\n------------- SIGN IN -----------------\n\n")
            self.navigationController = self.storyboard?.instantiateViewController(withIdentifier: "signinController") as? UINavigationController
        }

        if (self.signInViewController == nil) {
            self.signInViewController = self.navigationController?.viewControllers[0] as? SignInViewController
        }

        DispatchQueue.main.async {
            self.navigationController!.popToRootViewController(animated: true)
            if (!self.navigationController!.isViewLoaded
                    || self.navigationController!.view.window == nil) {
                self.window?.rootViewController?.present(self.navigationController!,
                        animated: true,
                        completion: nil)
            }
        }
        return self.signInViewController!
    }

    /* func startMultiFactorAuthentication() -> AWSCognitoIdentityMultiFactorAuthentication {
        if (self.mfaViewController == nil) {
            self.mfaViewController = MFAViewController()
            self.mfaViewController?.modalPresentationStyle = .popover
        }
        DispatchQueue.main.async {
            if (!self.mfaViewController!.isViewLoaded
                || self.mfaViewController!.view.window == nil) {
                //display mfa as popover on current view controller
                let viewController = self.window?.rootViewController!
                viewController?.present(self.mfaViewController!,
                                        animated: true,
                                        completion: nil)

                // configure popover vc
                let presentationController = self.mfaViewController!.popoverPresentationController
                presentationController?.permittedArrowDirections = UIPopoverArrowDirection.left
                presentationController?.sourceView = viewController!.view
                presentationController?.sourceRect = viewController!.view.bounds
            }
        }
        return self.mfaViewController!
    } */

    func startRememberDevice() -> AWSCognitoIdentityRememberDevice {
        return self
    }
}

// MARK:- AWSCognitoIdentityRememberDevice protocol delegate

extension AppDelegate: AWSCognitoIdentityRememberDevice {

    func getRememberDevice(_ rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>) {
        self.rememberDeviceCompletionSource = rememberDeviceCompletionSource
        DispatchQueue.main.async {
            // dismiss the view controller being present before asking to remember device
            self.window?.rootViewController!.presentedViewController?.dismiss(animated: true, completion: nil)
            let alertController = UIAlertController(title: "Remember Device",
                    message: "Do you want to remember this device?.",
                    preferredStyle: .actionSheet)

            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.rememberDeviceCompletionSource?.set(result: true)
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
                self.rememberDeviceCompletionSource?.set(result: false)
            })
            alertController.addAction(yesAction)
            alertController.addAction(noAction)

            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }

    func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                        message: error.userInfo["message"] as? String,
                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                DispatchQueue.main.async {
                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

class Settings {
    class func groupDefaults() -> UserDefaults {
        // initialize with suite name for extensions compatibility
        return UserDefaults(suiteName: "group.com.James.Defaults")!
    }

    class func registerDefaults(){
        let defaults = groupDefaults()
        defaults.register(defaults: [ onboardingKey : false ])
        defaults.synchronize()
    }
}
