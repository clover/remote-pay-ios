//
//  PreAuthViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
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
            let thisPreAuth = preAuths[indexPath.row]
            cell?.textLabel?.text = "x\(thisPreAuth.last4 ?? "----")    \(thisPreAuth.name ?? "")"
            cell?.detailTextLabel?.text = CurrencyUtils.IntToFormat(thisPreAuth.amount) ?? "$ ?.??"
        } else {
            cell?.textLabel?.text = "UNKNOWN"
        }
        
        
        return cell ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let store = (UIApplication.shared.delegate as? AppDelegate)?.store else { return }
        guard let cloverConnector = (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector else { return }
        guard let currentOrder = store.currentOrder else { return }
        if indexPath.row >= store.preAuths.count { return }
        let preAuthPayment = store.preAuths[indexPath.row]
        
        let alert = UIAlertController(title: "Pay with PreAuth", message: nil, preferredStyle: .alert)
        if currentOrder.getTotal() > 0 {
            alert.addAction(UIAlertAction(title: "Pay for Current Order", style: .default, handler: { [weak self] action in
                guard let cpar = self?.generateCPAR(payment: preAuthPayment) else { return }
                cloverConnector.capturePreAuth(cpar)
            }))
            alert.addAction(UIAlertAction(title: "Delete PreAuth", style: .destructive, handler: { action in
                store.removePreAuth(preAuthPayment)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        } else {
            alert.message = "Please create an order to apply to this PreAuth in the Register."
            alert.addAction(UIAlertAction(title: "Delete Pre-Auth", style: .destructive, handler: { action in
                store.removePreAuth(preAuthPayment)
            }))
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func generateCPAR(payment:POSPayment) -> CapturePreAuthRequest? {
        guard let store = (UIApplication.shared.delegate as? AppDelegate)?.store,
            let currentOrder = store.currentOrder else { return nil }
        let car = CapturePreAuthRequest(amount: currentOrder.getTotal(), paymentId: payment.paymentId)
        car.externalId = payment.externalPaymentId
        car.tipAmount = currentOrder.getTipAmount()
        car.tippableAmount = currentOrder.getTippableAmount()
        car.tipMode = store.transactionSettings.tipMode
        car.autoAcceptsSignature = store.transactionSettings.autoAcceptSignature
        if let cloverShouldHandleReceipts = store.transactionSettings.cloverShouldHandleReceipts {
            car.disablePrinting = !cloverShouldHandleReceipts
        }
        car.signatureEntryLocation = store.transactionSettings.signatureEntryLocation
        car.disableReceiptSelection = store.transactionSettings.disableReceiptSelection
        car.signatureThreshold = store.transactionSettings.signatureThreshold
        return car
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
    public func preAuthRemoved(_ payment:POSPayment){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    public func vaultCardAdded(_ card:POSCard){}
    public func manualRefundAdded(_ credit:POSNakedRefund){}
    // End POSStoreListener
}
