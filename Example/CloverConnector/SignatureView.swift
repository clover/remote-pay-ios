//
//  SignatureView.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

public class SignatureView : UIView {
    var sig:Signature?
    public override func drawRect(rect: CGRect) {
        //
        super.drawRect(rect)
        
        if let sig = sig {

            
            let width = frame.width
            //let height = frame.height
            
            var scale = 1.0
            if let sw = sig.width {
                scale = Double(width) / Double(sw)
            }
            
//            let widthMultiplier = sig.

            if let strokes = sig.strokes {
                for var stroke in strokes {
                    
                    let strokePath = UIBezierPath()
                    
                    if let points = stroke.points {
                        strokePath.moveToPoint(CGPoint(x: scale * Double(points[0].x!), y: scale * Double(points[0].y!)))
                        for (index, element) in points.enumerate() {
                            if(index > 0) {
                                strokePath.addLineToPoint(CGPoint(x: scale * Double(element.x!), y: scale * Double(element.y!)))
                            }
                        }
                    }
                    UIColor.blueColor().set()
                    strokePath.stroke()
                }
                
            }
            
//            context?.strokePath()

        }
        
    }
}
