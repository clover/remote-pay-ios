//
//  TabController.swift
//  CloverConnector
//
//  
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

class TabBarController : UITabBarController {
    
    override func viewDidLoad() {
        if let cc = (UIApplication.sharedApplication().delegate as? AppDelegate)?.cloverConnector {
            cc.addCloverConnectorListener(ConnectionListener(cloverConnector: cc, tabBar: self))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {

        
    }
    override func viewDidDisappear(_ animated: Bool) {

    
    }
    
    class ConnectionListener : DefaultCloverConnectorListener {
        
        var barController: TabBarController
        
        init(cloverConnector: ICloverConnector, tabBar:TabBarController) {
            self.barController = tabBar
            super.init(cloverConnector:cloverConnector)
        }
        
        override func onDeviceConnected() {
            dispatch_async(dispatch_get_main_queue()) {
                self.barController.tabBar.backgroundColor = UIColor.yellowColor()
            }
        }
        override func onDeviceDisconnected() {
            dispatch_async(dispatch_get_main_queue()) {
                self.barController.tabBar.backgroundColor = UIColor.redColor()
            }
        }
        override func onDeviceReady(merchantInfo: MerchantInfo) {
            dispatch_async(dispatch_get_main_queue()) {
                self.barController.tabBar.backgroundColor = UIColor.lightGrayColor()
            }
        }
        
        override func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
            // override and do nothing in this instance
        }
        
        override func onVerifySignatureRequest(signatureVerifyRequest: VerifySignatureRequest) {
            // override to do nothing in this instance
        }
    }
}
