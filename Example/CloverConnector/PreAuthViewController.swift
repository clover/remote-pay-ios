//
//  PreAuthViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

public class PreAuthViewController:UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var preAuthAmount: UITextField!
    
    @IBOutlet weak var preAuthButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    private func getStore() -> POSStore? {
        if let appDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate) {
            return appDelegate.store
        }
        return nil
    }
    
    public override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PreAuthViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PreAuthViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {

    }
    
    override public func viewDidAppear(animated: Bool) {
        getStore()?.addStoreListener(self)
    }
    
    override public func viewDidDisappear(animated: Bool) {
        getStore()?.removeStoreListener(self)
    }
    
    @IBAction func onAmountChanged(_ sender: UITextField) {
        
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getStore()?.preAuths.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell =  tableView.dequeueReusableCellWithIdentifier("PACell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "PACell")
        }
        
        var payment = getStore()?.manualRefunds.objectAtIndex(indexPath.row) as? POSPayment
        
        cell?.textLabel?.text = "\(CurrencyUtils.IntToFormat(payment!.amount) ?? "$ ?.??")"
        
        return cell!
    }
    
    @IBAction func onPreAuth(_ sender: UIButton) {
        
        tableView.becomeFirstResponder()
        if let amtText = preAuthAmount.text, let amt:Int = Int(amtText) {
            let request = PreAuthRequest(amount: amt, externalId: "\(arc4random())")
            (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.preAuth(request)
        }
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if preAuthAmount.editing {
            self.view.window?.frame.origin.y = -1 * getKeyboardHeight(notification)
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        if self.view.window?.frame.origin.y != 0 {
            self.view.window?.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    private func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        return keyboardHeight
    }
}


extension PreAuthViewController : POSStoreListener {
    // POSStoreListener
    public func newOrderCreated(_ order:POSOrder){}
    public func preAuthAdded(_ payment:POSPayment){
        dispatch_async(dispatch_get_main_queue()) {
            dispatch_after(2, dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    public func preAuthRemoved(_ payment:POSPayment){}
    public func vaultCardAdded(_ card:POSCard){}
    public func manualRefundAdded(_ credit:POSNakedRefund){}
    // End POSStoreListener
}
