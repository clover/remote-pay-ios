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
    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let sig = sig else { return }
        guard let strokes = sig.strokes else { return }
        
        let width = frame.width
        var scale = 1.0
        if let sw = sig.width {
            scale = Double(width) / Double(sw)
        }
        
        func point2CGPoint(point:Point?, scale:Double = 1) -> CGPoint? {
            guard let point = point,
                let x = point.x,
                let y = point.y else { return nil }
            return CGPoint(x: Double(x) * scale, y: Double(y) * scale)
        }

        for stroke in strokes {
            guard let points = stroke.points else { break }
            guard points.count > 0 else { break }
            let strokePath = UIBezierPath()
            
            // Move to the starting point
            guard let cgpoint = point2CGPoint(point: points.first, scale: scale) else { break }
            strokePath.move(to: cgpoint)
            
            // Add lines to the remaining points
            for (index, point) in points.enumerated() {
                if(index > 0) {
                    guard let cgpoint = point2CGPoint(point: point, scale: scale) else { break }
                    strokePath.addLine(to: cgpoint)
                }
            }
            
            UIColor.blue.set()
            strokePath.stroke()
        }
    }
}
