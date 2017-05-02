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
        /*
        if let sig = sig {

            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(2.0)
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let components:[CGFloat] = [0.0,0.5,1.0,1.0]
            let color = CGColor(colorSpace: colorSpace, components: components)
            context?.setStrokeColor(color!)
            
            let width = bounds.width
            let height = bounds.height
            
//            let widthMultiplier = sig.

            if let strokes = sig.strokes {
                for var stroke in strokes {
                    if let points = stroke.points {
                        for i in 1 .< points.count {
                            let point = points[i-1];
                            let point2 = points[i];
                            
                            
                            //move(to: context, CGFloat(point.x!) * 0.5, CGFloat(point.y!) * 0.5)
                            //CGContextMoveToPoint(context, CGFloat(point.x!) * 0.5, CGFloat(point.y!) * 0.5)
                            //CGContextAddLineToPoint(context, CGFloat(point2.x!) * 0.5, CGFloat(point2.y!) * 0.5)
                            
                            
                        }
                    }
                }
                
            }
            
            
            context?.strokePath()

        }*/
        
    }
}
