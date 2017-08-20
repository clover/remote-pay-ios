//
//  TestDetailsViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 CocoaPods. All rights reserved.
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
        debugPrint( String(self.navigationController) )
        if let name = testCase?.name {
            nameLabel.text = name + " : " + ((testCase?.passed?.0)! ? "✅" : "🛑")
        }
        textContent.text = testCase?.response ?? "<None/>"
    }
    
    
}
