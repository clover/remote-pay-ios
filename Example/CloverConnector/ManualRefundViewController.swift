//
//  ManualRefundViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

class ManualRefundViewController:UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var refundAmount: UITextField!
    
    @IBOutlet weak var refundButton: UIButton!
    @IBOutlet weak var manualRefundsTable: UITableView!
    
    private func getStore() -> POSStore? {
        if let appDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate) {
            return appDelegate.store
        }
        return nil
    }
    
    public override func viewDidLoad() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ManualRefundViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ManualRefundViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        getStore()?.addStoreListener(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        getStore()?.removeStoreListener(self)
    }
    
    deinit {

    }
    
    
    @IBAction func onManualRefund(_ sender: UIButton) {
        manualRefundsTable.becomeFirstResponder()
        
        if let amtText = refundAmount.text, let amt:Int = Int(amtText) {
            let request = ManualRefundRequest(amount: amt, externalId: "\(arc4random())")
            (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.manualRefund(request)
        }
        
    }
    
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if refundAmount.editing {
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getStore()?.manualRefunds.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell =  manualRefundsTable.dequeueReusableCellWithIdentifier("MRCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "MRCell")
        }
        
        var manualRefund = getStore()?.manualRefunds.objectAtIndex(indexPath.row) as? POSNakedRefund
        
        cell?.textLabel?.text = "\(CurrencyUtils.IntToFormat(manualRefund!.amount) ?? "$ ?.??")"
        
        return cell!
    }
    
    

    
}

extension ManualRefundViewController : POSStoreListener {
    // POSStoreListener
    func newOrderCreated(_ order:POSOrder){}
    func preAuthAdded(_ payment:POSPayment){}
    func preAuthRemoved(_ payment:POSPayment){}
    func vaultCardAdded(_ card:POSCard){}
    func manualRefundAdded(_ credit:POSNakedRefund){
        dispatch_async(dispatch_get_main_queue()) {
            dispatch_after(2, dispatch_get_main_queue(), {
                self.manualRefundsTable.reloadData()
            })
        }
    }
    // End POSStoreListener
}
