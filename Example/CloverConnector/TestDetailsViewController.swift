//
//  TestDetailsViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import UIKit

class TestDetailsViewController : UIViewController {
    public var testCase:Case?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textContent: UITextView!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint( String(describing: self.navigationController) )
        if let name = testCase?.name,
            let passed = testCase?.passed?.0 {
            nameLabel.text = "\(name) : \(passed ? "✅" : "🛑")"
        }
        textContent.text = testCase?.response ?? "<None/>"
    }
    
    
}
