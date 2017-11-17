//
//  TabController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

class TabBarController : UITabBarController {
    
    override func viewDidLoad() {
        if let cc = (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector {
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
            DispatchQueue.main.async {
                self.barController.tabBar.backgroundColor = UIColor.yellow
            }
        }
        override func onDeviceDisconnected() {
            DispatchQueue.main.async {
                self.barController.tabBar.backgroundColor = UIColor.red
            }
        }
        override func onDeviceReady(_ merchantInfo: MerchantInfo) {
            DispatchQueue.main.async {
                self.barController.tabBar.backgroundColor = UIColor.lightGray
            }
        }
        
        override func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
            // override and do nothing in this instance
        }
        
        override func onVerifySignatureRequest(_ signatureVerifyRequest: VerifySignatureRequest) {
            // override to do nothing in this instance
        }
    }
}
