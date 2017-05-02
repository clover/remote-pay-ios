//
//  SignatureViewController.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

public class SignatureViewController:UIViewController {
    public var signatureVerifyRequest:VerifySignatureRequest?
    
    @IBOutlet weak var signatureView: SignatureView!
    
    public override func viewDidLoad() {
        signatureView.sig = signatureVerifyRequest?.signature
    }
    
    @IBAction func rejectSignature(sender: UIButton) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.rejectSignature(signatureVerifyRequest!)
        dismissViewControllerAnimated(true, completion: {})
        
    }
    @IBAction func acceptSignature(sender: UIButton) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.acceptSignature(signatureVerifyRequest!)
        dismissViewControllerAnimated(true, completion: {})
    }
}
