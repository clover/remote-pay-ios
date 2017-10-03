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
    
    @IBAction func rejectSignature(_ sender: UIButton) {
        guard let signatureVerifyRequest = signatureVerifyRequest else { return }
        (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector?.rejectSignature(signatureVerifyRequest)
        dismiss(animated: true, completion: {})
        
    }
    @IBAction func acceptSignature(_ sender: UIButton) {
        guard let signatureVerifyRequest = signatureVerifyRequest else { return }
        (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector?.acceptSignature(signatureVerifyRequest)
        dismiss(animated: true, completion: {})
    }
}
