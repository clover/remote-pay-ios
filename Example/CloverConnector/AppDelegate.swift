//
//  AppDelegate.swift
//  CloverConnector
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import UIKit
import CloverConnector
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PairingDeviceConfiguration {

    var window: UIWindow?
    
    public var cloverConnector:ICloverConnector?
    public var cloverConnectorListener:CloverConnectorListener?
    public var testCloverConnectorListener:TestCloverConnectorListener?
    public var store:POSStore?
    private var token:String?

    private let PAIRING_AUTH_TOKEN_KEY:String = "PAIRING_AUTH_TOKEN"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        store = POSStore()
        store?.availableItems = NSMutableArray()
        store?.availableItems.addObject(POSItem(id: "\(arc4random())", name: "Cheeseburger", price: 579, taxRate: 0.075, taxable: true))
        store?.availableItems.addObject(POSItem(id: "\(arc4random())", name: "Hamburger", price: 529, taxRate: 0.075, taxable: true))
        store?.availableItems.addObject(POSItem(id: "\(arc4random())", name: "Bacon Cheeseburger", price: 619, taxRate: 0.075, taxable: true))
        store?.availableItems.addObject(POSItem(id: "\(arc4random())", name: "Chicken Nuggets", price: 569, taxRate: 0.075, taxable: true))
        store?.availableItems.addObject(POSItem(id: "\(arc4random())", name: "Large Fries", price: 239, taxRate: 0.075, taxable: true))
        store?.availableItems.addObject(POSItem(id: "\(arc4random())", name: "Small Fries", price: 179, taxRate: 0.075, taxable: true))
        store?.availableItems.addObject(POSItem(id: "\(arc4random())", name: "Vanilla Milkshake", price: 229, taxRate: 0.075, taxable: true))
        store?.availableItems.addObject(POSItem(id: "\(arc4random())", name: "Chocolate Milkshake", price: 229, taxRate: 0.075, taxable: true))
        store?.availableItems.addObject(POSItem(id: "\(arc4random())", name: "Strawberry Milkshake", price: 229, taxRate: 0.075, taxable: true))
        store?.availableItems.addObject(POSItem(id: "\(arc4random())", name: "$25 Gift Card", price: 2500, taxRate: 0.00, taxable: false, tippable: false))
        store?.availableItems.addObject(POSItem(id: "\(arc4random())", name: "$50 Gift Card", price: 5000, taxRate: 0.000, taxable: false, tippable: false))
        
        if let tkn = NSUserDefaults.standardUserDefaults().stringForKey( PAIRING_AUTH_TOKEN_KEY) {
            token = tkn
        }
        
        return true
    }
    
    
    func onPairingCode(pairingCode: String) {
        print("Pairing Code: \(pairingCode)")
        self.cloverConnectorListener?.onPairingCode(pairingCode)
    }
    func onPairingSuccess(authToken: String) {
        print("Pairing Auth Token: \(authToken)")
        self.cloverConnectorListener?.onPairingSuccess(authToken)
        self.token = authToken
        NSUserDefaults.standardUserDefaults().setObject(self.token, forKey: PAIRING_AUTH_TOKEN_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func clearConnect(_ url:String) {
        self.token = nil
        connect(url)
    }
    
    func connect(_ url:String) {
        cloverConnector?.dispose()
        
        let config:WebSocketDeviceConfiguration = WebSocketDeviceConfiguration(endpoint:url, remoteApplicationID: "com.clover.ios.example.app", posName: "iOS Example POS", posSerial: "POS-15", pairingAuthToken: self.token, pairingDeviceConfiguration: self)
        config.disableSSLValidation = true
        if let cc = cloverConnector {
            cc.dispose() // if connect is clicked again...
        }
        cloverConnector = CloverConnector(config: config);
        cloverConnectorListener = CloverConnectorListener(cloverConnector: cloverConnector!)
        cloverConnectorListener?.viewController = self.window?.rootViewController
        testCloverConnectorListener = TestCloverConnectorListener(cloverConnector: cloverConnector! as! CloverConnector)
        cloverConnector!.addCloverConnectorListener(cloverConnectorListener!)
        cloverConnector!.initializeConnection()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // this gets called for a notification while the app is the active app
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {

    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
    }

}

