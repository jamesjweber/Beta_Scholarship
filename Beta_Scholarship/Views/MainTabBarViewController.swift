//
//  MainTabBarViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/16/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class MainTabBarViewController: UITabBarController {

    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    let cache = NSCache<NSString, userInformation>()
    var userInfo: userInformation?
    var blurEffectView: UIVisualEffectView?

    override func viewDidLoad() {
        super.viewDidLoad()

        /* let blurEffect = UIBlurEffect(style: .prominent)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView?.frame = self.view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(blurEffectView!) //if you have more UIViews, use an insertSubview API to place it where needed

        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }

        refresh() */
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /* func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
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
                        // This section will get the user's house positions and will only allow
                        // scholarship committee members access to the user info view
                        //
                        // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
                        if let currentUser = self.userInfo {
                            //print("yooo")
                            let housePositions = currentUser.house_positions
                            let housePositionsArr = housePositions?.components(separatedBy: ", ")
                            var canSeeUserInfoTab = false
                            for position in housePositionsArr! {
                                //"Scholarship Chair", "Scholarship Committee Member",
                                if (position == "Scholarship Chair" || position == "Scholarship Committee Member") {
                                    print("baller")
                                    canSeeUserInfoTab = true
                                }
                            }
                            if (!canSeeUserInfoTab) {
                                print("problem?")
                                self.viewControllers?.remove(at: 0)
                                print("uh yeah")
                            }
                            self.blurEffectView!.removeFromSuperview()
                        }
                    }
                })
                return nil
            }
            return nil
        }

    } */

}
