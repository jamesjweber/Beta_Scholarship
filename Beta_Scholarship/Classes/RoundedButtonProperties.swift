//
//  RoundedButtonProperties.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/4/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import Foundation
import UIKit

func configureButton(button: UIButton, view: UIViewController) {
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    button.layer.masksToBounds = false
    button.layer.shadowRadius = 4.0
    button.layer.shadowOpacity = 0.16
}
