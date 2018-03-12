//
//  GradientBackgroundView.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/20/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit

class GradientBackgroundView: UIView {

    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.white.cgColor, UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0).cgColor]
    }
}
