//
//  PreAuthViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

public class PreAuthViewController:UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var preAuthAmount: UITextField!
    
    @IBOutlet weak var preAuthButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var store:POSStore? {
        get {
            return (UIApplication.shared.delegate as? AppDelegate)?.store
        }
    }
    
    fileprivate func getStore() -> POSStore? {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            return appDelegate.store
        }
        return nil
    }

    
    deinit {

    }
    
    override public func viewDidAppear(_ animated: Bool) {
        getStore()?.addStoreListener(self)
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main, using: {[weak self] notification in
            guard let strongSelf = self else { return }
            if strongSelf.preAuthAmount.isFirstResponder {
                strongSelf.view.window?.frame.origin.y = -1 * ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0)
            }
        })
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main, using: {[weak self] notification in
            guard let strongSelf = self else { return }
            if strongSelf.view.window?.frame.origin.y != 0 {
                strongSelf.view.window?.frame.origin.y += ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0)
            }
        })
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        getStore()?.removeStoreListener(self)

        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getStore()?.preAuths.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell =  tableView.dequeueReusableCell(withIdentifier: "PACell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "PACell")
        }
        
        if let preAuths = getStore()?.preAuths, indexPath.row < preAuths.count {
            cell?.textLabel?.text = CurrencyUtils.IntToFormat(preAuths[indexPath.row].amount) ?? "$ ?.??"
        } else {
            cell?.textLabel?.text = "UNKNOWN"
        }
        
        
        return cell ?? UITableViewCell()
    }
    
    @IBAction func onPreAuth(_ sender: UIButton) {
        preAuthAmount.resignFirstResponder()
        
        if let amtText = preAuthAmount.text, let amt:Int = Int(amtText) {
            let externalId = String(arc4random())
            (UIApplication.shared.delegate as? AppDelegate)?.cloverConnectorListener?.preAuthExpectedResponseId = externalId
            let par = PreAuthRequest(amount: amt, externalId: externalId)
            // below are all optional
            if let enablePrinting = store?.transactionSettings.cloverShouldHandleReceipts {
                par.disablePrinting = !enablePrinting
            }
            par.disableReceiptSelection = store?.transactionSettings.disableReceiptSelection
            par.disableRestartTransactionOnFail = store?.transactionSettings.disableRestartTransactionOnFailure
            
            (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector?.preAuth(par)
        }
    }
    
    
    fileprivate func getKeyboardHeight(_ notification: Notification) -> CGFloat? {
        return (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
    }
}


extension PreAuthViewController : POSStoreListener {
    // POSStoreListener
    public func newOrderCreated(_ order:POSOrder){}
    public func preAuthAdded(_ payment:POSPayment){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    public func preAuthRemoved(_ payment:POSPayment){}
    public func vaultCardAdded(_ card:POSCard){}
    public func manualRefundAdded(_ credit:POSNakedRefund){}
    // End POSStoreListener
}
