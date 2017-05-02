//
//  VaultCardViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

public class VaultCardViewController:UIViewController, UITableViewDataSource
{
    
    @IBOutlet weak var tableView: UITableView!
    
    private func getStore() -> POSStore? {
        if let appDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate) {
            return appDelegate.store
        }
        return nil
    }
    
    public override func viewDidLoad() {
    }
    
    deinit {
        
    }
    
    override public func viewDidAppear(animated: Bool) {
        getStore()?.addStoreListener(self)
    }
    
    override public func viewDidDisappear(animated: Bool) {
        getStore()?.removeStoreListener(self)
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getStore()?.vaultedCards.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //        let cell:UITableViewCell = manualRefundsTable.dequeueReusableCellWithIdentifier(withIdentifier: "ManualRefundCell")
        
        var cell =  tableView.dequeueReusableCellWithIdentifier("VCCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "VCCell")
        }
        
        var card = getStore()?.vaultedCards.objectAtIndex(indexPath.row) as? POSCard
        
        cell?.textLabel?.text = "\(card?.first6 ?? "------")-XXXXXX-\(card?.last4 ?? "------")"
        cell?.detailTextLabel?.text = "\(card?.token ?? "---")"
        
        return cell!
    }
    
    @IBAction func onVaultCard(_ sender: UIButton) {
        tableView.becomeFirstResponder()
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.vaultCard(VaultCardRequest())
    }
    
    private func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        return keyboardHeight
    }
}


extension VaultCardViewController : POSStoreListener {
    // POSStoreListener
    public func newOrderCreated(_ order:POSOrder){}
    public func preAuthAdded(_ payment:POSPayment){
    }
    public func preAuthRemoved(_ payment:POSPayment){}
    public func vaultCardAdded(_ card:POSCard){
        dispatch_async(dispatch_get_main_queue()) {
            dispatch_after(2, dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    public func manualRefundAdded(_ credit:POSNakedRefund){}
    // End POSStoreListener
}
