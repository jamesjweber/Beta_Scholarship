//
//  Colors.swift
//  Beta_Scholarship
//
//  Created by James Weber on 2/28/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit

class Colors: UIColor {
    let red = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    let blue = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    let yellow = UIColor(red: 255/255, green: 219/255, blue: 69/255, alpha: 1)
    let green = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
    let orange = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
    let purple = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
    let hazel = UIColor(red: 0/255, green: 168/255, blue: 149/255, alpha: 1)
    let royal_purple = UIColor(red: 113/255, green: 0/255, blue: 155/255, alpha: 1)
    let light_blue = UIColor(red: 0/255, green: 163/255, blue: 237/255, alpha: 1)
    let woodland_green =  UIColor(red: 53/255, green: 155/255, blue: 70/255, alpha: 1)
    //#359B46
    let white = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    let light_gray = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1)
    let light_gray_2 = UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1)
    let mid_gray = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1)
    let gray = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1)
    let black = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    let off_black = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1)

    func color(named: String) -> UIColor {
        switch named {
        case "blue":
            return blue
        case "red":
            return red
        case "yellow":
            return yellow
        case "green":
            return green
        case "orange":
            return orange
        case "purple":
            return purple
        case "hazel":
            return hazel
        case "royal purple":
            return royal_purple
        case "woodland green":
            return woodland_green
        case "light blue":
            return light_blue
        case "white":
            return white
        case "light gray":
            return light_gray
        case "light gray 2":
            return light_gray_2
        case "mid gray":
            return mid_gray
        case "gray":
            return gray
        case "off black":
            return off_black
        case "black":
            return black
        default:
            return black
        }
    }

}
