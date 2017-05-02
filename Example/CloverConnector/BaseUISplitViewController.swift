//
//  BaseUISplitViewController.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit

public class BaseUISplitViewController : UISplitViewController, UISplitViewControllerDelegate {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool{
        return true
    }
    
}
