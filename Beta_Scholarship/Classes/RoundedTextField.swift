//
//  RoundedTextField.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/20/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit

class RoundedTextField: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 22.5
        self.layer.masksToBounds = true
        self.textColor = UIColor.darkText
        self.font = UIFont(name: "AppleSDGothicNeo-Light" , size: 18)
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 0.25
    }
    
    let padding = UIEdgeInsets(top: 0, left: 22.5, bottom: 0, right: 22.5);

    // Padding for place holder
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    // Padding for text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    // Padding for text in editting mode
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

}
