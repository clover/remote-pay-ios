//
//  ManualRefundViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

class ManualRefundViewController:UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var refundAmount: UITextField!
    
    @IBOutlet weak var refundButton: UIButton!
    @IBOutlet weak var manualRefundsTable: UITableView!
    
    fileprivate func getStore() -> POSStore? {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            return appDelegate.store
        }
        return nil
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        getStore()?.addStoreListener(self)
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main, using: {[weak self] notification in
            guard let strongSelf = self else { return }
            if strongSelf.refundAmount.isFirstResponder {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        getStore()?.removeStoreListener(self)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {

    }
    
    
    @IBAction func onManualRefund(_ sender: UIButton) {
        refundAmount.resignFirstResponder()
        
        if let amtText = refundAmount.text, let amt:Int = Int(amtText) {
            let request = ManualRefundRequest(amount: amt, externalId: String(arc4random()))
            (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector?.manualRefund(request)
        }
        
    }
    
    

    
    fileprivate func getKeyboardHeight(_ notification: Notification) -> CGFloat? {
        return (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getStore()?.manualRefunds.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell =  manualRefundsTable.dequeueReusableCell(withIdentifier: "MRCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "MRCell")
        }
        
        if let refunds = getStore()?.manualRefunds, indexPath.row < refunds.count {
            cell?.textLabel?.text = CurrencyUtils.IntToFormat(refunds[indexPath.row].amount) ?? "$ ?.??"
        } else {
            cell?.textLabel?.text = "UNKNOWN"
        }
        
        return cell ?? UITableViewCell()
    }
    
    

    
}

extension ManualRefundViewController : POSStoreListener {
    // POSStoreListener
    func newOrderCreated(_ order:POSOrder){}
    func preAuthAdded(_ payment:POSPayment){}
    func preAuthRemoved(_ payment:POSPayment){}
    func vaultCardAdded(_ card:POSCard){}
    func manualRefundAdded(_ credit:POSNakedRefund){
        DispatchQueue.main.async {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                self.manualRefundsTable.reloadData()
            })
        }
    }
    // End POSStoreListener
}
