//
//  ViewController.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import UIKit
import CloverConnector
import Intents

class ViewController: UIViewController {

    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var endpointTextField: UITextField!
    
    private let WS_ENDPOINT = "WS_ENDPOINT"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedEndpoint = NSUserDefaults.standardUserDefaults().stringForKey(WS_ENDPOINT) {
            endpointTextField.text = savedEndpoint
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func longPressConnect(sender: UIButton) {
        connect(true)
    }
    @IBAction func tapConnect(sender: AnyObject) {
        connect(false)
    }
    
    private func connect(forcePairing:Bool) {
        if let endpoint = endpointTextField.text {
            debugPrint(endpoint)
            NSUserDefaults.standardUserDefaults().setValue(endpoint, forKey: WS_ENDPOINT)
            if forcePairing {
                (UIApplication.sharedApplication().delegate as! AppDelegate).clearConnect(endpoint)
            } else {
                (UIApplication.sharedApplication().delegate as! AppDelegate).connect(endpoint)
            }
        }
    }
    

}

