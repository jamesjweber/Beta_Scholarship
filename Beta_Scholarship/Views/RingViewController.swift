//
//  RingViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/2/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit

class RingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*let width = view.frame.width
        let height = view.frame.height
        
        print(width)
        print(height)
        
        let ring = rings(center: CGPoint(x: width/2, y: height/2), color: Colors().red, percentage: 8/12)
        let ring2 = rings(center: CGPoint(x: width/2, y: 209), color: Colors().blue, percentage: 1.5/2.4)
        let ring3 = rings(center: CGPoint(x: width - 77.5, y: 209), color: Colors().yellow, percentage: 36/(12*16))
        
        view.layer.addSublayer(ring.trackLayer)
        view.layer.addSublayer(ring.shapeLayer)
        
        view.layer.addSublayer(ring2.trackLayer)
        view.layer.addSublayer(ring2.shapeLayer)
        
        view.layer.addSublayer(ring3.trackLayer)
        view.layer.addSublayer(ring3.shapeLayer)*/
        
        
        class rings {
            let shapeLayer = CAShapeLayer()
            let trackLayer = CAShapeLayer()
            
            let radius = 45
            
            init(center: CGPoint, color: UIColor, percentage: Double) {
                let circularPath = UIBezierPath(arcCenter: center, radius: CGFloat(radius), startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi, clockwise: true)
                
                print("percentage: " + String(percentage))
                let rad = (CGFloat(percentage)*2*CGFloat.pi)
                print(rad)
                
                let circularPath2 = UIBezierPath(arcCenter: center, radius: CGFloat(radius), startAngle: -CGFloat.pi/2, endAngle: rad-CGFloat.pi/2, clockwise: true)
                
                self.addTrackLayer(path: circularPath.cgPath, color: color)
                
                shapeLayer.path = circularPath2.cgPath
                shapeLayer.fillColor = UIColor.clear.cgColor
                
                shapeLayer.shadowColor = UIColor.black.cgColor
                shapeLayer.shadowOffset = CGSize(width: -3.0, height: 3.0)
                shapeLayer.shadowOpacity = 0.3
                shapeLayer.shadowRadius = 8.0
                //shapeLayer.shouldRasterize = true
                
                shapeLayer.lineCap = kCALineCapRound
                
                shapeLayer.strokeColor = color.cgColor
                shapeLayer.lineWidth = 14
            }
            
            
            func addTrackLayer(path:CGPath, color: UIColor) {
                // Track Layer
                trackLayer.path = path
                trackLayer.fillColor = UIColor.clear.cgColor
                
                trackLayer.strokeColor = color.withAlphaComponent(0.2).cgColor
                trackLayer.lineWidth = 14
            }
        }
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

}
