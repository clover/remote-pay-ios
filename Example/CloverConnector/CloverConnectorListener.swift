//
//  CloverConnectorListener.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

public class CloverConnectorListener : NSObject, ICloverConnectorListener, UIAlertViewDelegate {
    weak var cloverConnector:ICloverConnector?
    
    public var parentViewController:UIViewController?
    private var uiAlertController:UIAlertController?
    private var lastDeviceEvent:CloverDeviceEvent?
    private var paymentConfirmDel:UIAlertViewDelegate?
    
    var viewController:UIViewController?
    
    private var ready:Bool = false
    
    public init(cloverConnector:ICloverConnector){
        self.cloverConnector = cloverConnector;
    }
    
    private func getStore() -> POSStore? {
        if let appDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate) {
            return appDelegate.store
        }
        return nil
    }
    
    class Arg:NSObject {
        var view:UIAlertView
        var completion:(()->Void)?
        init(view v:UIAlertView, completion c:(()->Void)?) {
            view = v
            completion = c
        }
    }
    
    @objc private func dismissMessage(_ arg:Arg) {
        dispatch_async(dispatch_get_main_queue(), {
            arg.view.dismissWithClickedButtonIndex( -1, animated: true)
            if let comp = arg.completion {
                comp()
            }
        })
    }
    
    private func showMessage(_ message:String, duration:Int = 3, completion: (()->Void)? = {}) {

        dispatch_async(dispatch_get_main_queue()){
            let alertView:UIAlertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
            alertView.show()
            self.performSelector(#selector(self.dismissMessage), withObject: Arg(view: alertView, completion: completion), afterDelay: NSTimeInterval(duration))
        }

    }
    
    /*
     * Response to a sale request.
     */
    public func  onSaleResponse ( _ response:SaleResponse ) -> Void {
        if response.success {
            if let store = getStore() {
                if let payment = response.payment,
                    let order = store.currentOrder { // assuming current order, but should verify by checking the payment's external id
                    let tipAmount = payment.tipAmount ?? 0
                    let cashback = payment.cashbackAmount ?? 0
                    let posPayment:POSPayment = POSPayment(paymentId: payment.id!, externalPaymentId: payment.externalPaymentId, orderId: payment.order!.id!, employeeId: "DFLTEMPLYEE", amount: payment.amount!, tipAmount: tipAmount, cashbackAmount: cashback)
                    
                    posPayment.status = response.isSale ? PaymentStatus.PAID : (response.isAuth ? PaymentStatus.AUTHORIZED : (response.isPreAuth ? PaymentStatus.PREAUTHORIZED : PaymentStatus.UNKNOWN))
                    
                    var expectedResponseId = true
                    if order.pendingPaymentId != payment.externalPaymentId {
                        expectedResponseId = false
                    }
                    
                    if response.isSale || response.isAuth {
                        store.addPaymentToOrder(posPayment, order: order)
                        if response.isSale {
                            if expectedResponseId {
                                showMessage("Sale successfully processed")
                            } else {
                                showMessage("Sale successful, but unexpected payment id")
                            }
                        } else if response.isAuth {
                            if expectedResponseId {
                                showMessage("Sale processed as Auth successfully processed")
                            } else {
                                showMessage("Sale processed as Auth, but unexpected payment id")
                            }
                        }
                        store.newOrder()
                        cloverConnector?.showWelcomeScreen()
                    } else if response.isPreAuth {
                        store.addPreAuth(posPayment)
                        showMessage("Sale processed as Pre-Auth successful")
                    }
                }
            }
        } else {
            if response.result == .CANCEL {
                showMessage("Sale canceled")
            } else if response.result == .FAIL {
                showMessage("Sale Tx Failed")
            } else {
                showMessage(response.result.rawValue);
            }
        }
    }
    
    /*
     * Response to an auth request
     */
    public func onAuthResponse(_ authResponse: AuthResponse) {
        if authResponse.success {
            if let store = getStore() {
                if let payment = authResponse.payment,
                    let order = store.currentOrder {
                    let tipAmount = payment.tipAmount ?? 0
                    let cashback = payment.cashbackAmount ?? 0
                    let posPayment:POSPayment = POSPayment(paymentId: payment.id!, externalPaymentId: payment.externalPaymentId, orderId: payment.order!.id!, employeeId: "DFLTEMPLYEE", amount: payment.amount!, tipAmount: tipAmount, cashbackAmount: cashback)
                    
                    posPayment.status = authResponse.isSale ? PaymentStatus.PAID : (authResponse.isAuth ? PaymentStatus.AUTHORIZED : (authResponse.isPreAuth ? PaymentStatus.PREAUTHORIZED : PaymentStatus.UNKNOWN))
                    
                    if authResponse.isSale || authResponse.isAuth {
                        store.addPaymentToOrder(posPayment, order: order)
                        if authResponse.isSale {
                            showMessage("Sale successfully processed")
                        } else if authResponse.isAuth {
                            showMessage("Auth successfully processed")
                        }
                        store.newOrder()
                        cloverConnector?.showWelcomeScreen()
                    } else if authResponse.isPreAuth {
                        store.addPreAuth(posPayment)
                        showMessage("Pre-Auth successful")
                    }
                }
            }
        } else {
            if authResponse.result == .CANCEL {
                showMessage("Auth canceled")
            } else if authResponse.result == .FAIL {
                showMessage("Auth Tx Failed")
            } else {
                showMessage(authResponse.result.rawValue);
            }
        }
    }
    
    /*
     * response to a pre-auth request
     */
    public func onPreAuthResponse(_ preAuthResponse: PreAuthResponse) {
        if preAuthResponse.success {
            showMessage("PreAuth successful")
            if let store = getStore() {
                if let payment = preAuthResponse.payment {
                    let posPayment:POSPayment = POSPayment(paymentId: payment.id!, externalPaymentId: payment.externalPaymentId, orderId: payment.order!.id!, employeeId: "DFLTEMPLYEE", amount: payment.amount!, tipAmount: payment.tipAmount ?? 0, cashbackAmount: payment.cashbackAmount ?? 0)
                    store.addPreAuth(posPayment)
                }
            }
        } else {
            if preAuthResponse.result == .CANCEL {
                showMessage("Pre Auth Canceled")
            } else if preAuthResponse.result == .FAIL {
                showMessage("PreAuth failed")
            } else {
                showMessage(preAuthResponse.result.rawValue)
            }
        }
    }
    
    
    /*
     * Response to a preauth being captured.
     */
    public func  onCapturePreAuthResponse ( _ response:CapturePreAuthResponse ) -> Void {
        if response.success {
            if let store = getStore() {
                for paymentObj in store.preAuths {
                    if let payment = paymentObj as? POSPayment {
                        if payment.paymentId == response.paymentId {
                            let paymentAmount = payment.amount
                            store.removePreAuth(payment)
                            store.addPaymentToOrder(payment, order: store.currentOrder!)
                            payment.status = PaymentStatus.AUTHORIZED
                            payment.amount = paymentAmount
                            showMessage("Sale successful processing using Pre Authorization")
                            store.newOrder()
                        }
                        break;
                    } else {
                        showMessage("PreAuth Capture: Payment received does not match any of the stored PreAuth records");
                    }
                }
            } else {
                showMessage("Couldn't get store!")
            }
        } else {
            showMessage("PreAuth Capture Error: Payment failed with response code = \(response.result) and reason: \(response.reason)")
        }
    }
    
    
    /*
     * Response to a tip adjustment for an auth.
     */
    public func  onTipAdjustAuthResponse ( _ response:TipAdjustAuthResponse ) -> Void {
        if response.success {
            if let store = getStore() {
                var updatedTip = false
                for order in store.orders {
                    if let order = order as? POSOrder {
                        for exchange in order.payments {
                            if let exchange = exchange as? POSPayment {
                                if exchange.paymentId == response.paymentId {
                                    updatedTip = true;
                                    break;
                                }
                            } else {
                                showMessage("Invalid payment!")
                            }
                        }
                    } else {
                        showMessage("Invalid Order!")
                    }
                }
                if (updatedTip) {
                    showMessage("Tip successfully adjusted")
                }
            }
        } else {
            showMessage("Tip adjust failed")
        }
    }
    
    
    /*
     * Response to a payment be voided.
     */
    public func  onVoidPaymentResponse ( _ response:VoidPaymentResponse ) -> Void {
        if response.success {
            var done = false;
            if let store = getStore() {
                for order in store.orders {
                    if let order = order as? POSOrder {
                        for payment in order.payments {
                            if let payment = payment as? POSPayment {
                                if payment.paymentId == response.paymentId {
                                    payment.status = .VOIDED
                                    showMessage("Payment was voided")
                                    done = true;
                                    break;
                                }
                            }
                        }
                        if (done) {
                            break;
                        }
                    }
                }
            }
        } else {
            showMessage("There was an error voiding payment: \(response.result)")
        }
    }
    
    
    /*
     * Response to a payment being refunded.
     */
    public func  onPaymentRefundResponse ( _ response:RefundPaymentResponse ) -> Void {
        if response.success {
            let refund = POSRefund(refundId: response.refund!.id!, paymentId: response.paymentId!, orderID: response.orderId!, employeeId: "DFLTEMPLYEE", amount: response.refund!.amount!)
            var done = false
            if let store = getStore() {
                for order in store.orders {
                    if let order = order as? POSOrder {
                        for payment in order.payments {
                            if let payment = payment as? POSPayment {
                                if payment.paymentId == response.refund!.payment?.id {
                                    payment.status = .REFUNDED
                                    store.addRefundToOrder(refund, order: order)
                                    done = true
                                }
                            }
                            if done {
                                break;
                            }
                        }
                    }
                    if done {
                        break;
                    }
                }
            }
        } else {
            showMessage("There was an error refunding a payment: \(response.result)")
        }

    }
    
    
    /*
     * Response to an amount being refunded.
     */
    public func  onManualRefundResponse ( _ manualRefundResponse:ManualRefundResponse ) -> Void {
        if manualRefundResponse.success {
            if let store = getStore() {
                if let amt = manualRefundResponse.credit?.amount {
                    let nakedRefund = POSNakedRefund(employeeId:"DFLTEMPLYE", amount: amt)
                    store.addManualRefund(nakedRefund)
                }
            }
        } else {
            if manualRefundResponse.result == .CANCEL {
                showMessage("Manual Refund Canceled")
            } else if manualRefundResponse.result == .FAIL {
                showMessage("Manual Refund failed")
            } else {
                showMessage(manualRefundResponse.result.rawValue)
            }
        }
    }
    
    
    /*
     * Response to a closeout.
     */
    public func  onCloseoutResponse ( _ response:CloseoutResponse ) -> Void {
        if response.success {
            showMessage("Closeout complete for batch: \(response.batch?.id)")
        } else {
            showMessage("Error scheduling closeout: \(response.reason)")
        }
    }
    
    
    /*
     * Receives signature verification requests.
     */
    public func  onVerifySignatureRequest ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void {
        dispatch_async(dispatch_get_main_queue()){
            if let view = self.uiAlertController {
                view.dismissViewControllerAnimated(false, completion: {
                    self.onVerifySignatureRequest(signatureVerifyRequest)
                })
            } else {
                if var topViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                    while let presentedViewController = topViewController.presentedViewController {
                        topViewController = presentedViewController
                    }
                    
                    if let tvc = topViewController as? TabBarController {
                        if let rvc = tvc.selectedViewController as? RegisterViewController {
                            rvc.verifySignature(signatureVerifyRequest)
                        } else {
                            
                            let acceptVC = UIAlertController(title: "Accept Signature?", message: nil, preferredStyle: .Alert)
                            acceptVC.addAction(UIAlertAction(title: "Accept", style: .Cancel, handler: { (aa) in
                                self.cloverConnector?.acceptSignature(signatureVerifyRequest)
                            }))
                            acceptVC.addAction(UIAlertAction(title: "Reject", style: .Default, handler: { (aa) in
                                self.cloverConnector?.rejectSignature(signatureVerifyRequest)
                            }))
                            topViewController.presentViewController(acceptVC, animated: true, completion: nil)
                            
                        }

                    }
                }
                
            }
        }
    }
    
    
    
    /*
     * Response to vault a card.
     */
    public func  onVaultCardResponse ( _ response:VaultCardResponse ) -> Void {
        if response.success {
            let s:NSString = ""
            if let exp = response.card?.expirationDate,
                let token = response.card?.token,
                let store = getStore() {
                let card:POSCard = POSCard(name: response.card?.cardholderName ?? "", first6: (response.card?.first6)!, last4: (response.card?.last4) ?? "", month: (exp as NSString).substringToIndex(2), year: (exp as NSString).substringFromIndex(2), token: token)
                        store.addVaultedCard(card)
                        showMessage("Card successfully vaulted")
            } else {
                showMessage("Error with card data")
            }
            
        } else {
            showMessage("Error capturing card")
        }
    }
    
    
    /*
     * called when the device is initially connected
     */
    public func  onConnected () -> Void {}
    
    
    /*
     * called when the device is ready to communicate
     */
    public func  onReady (_ merchantInfo: MerchantInfo) -> Void {}
    
    
    /*
     * called when the device is disconnected, or not responding
     */
    public func  onDisconnected () -> Void {}
    
    public func onDeviceActivityEnd(_ deviceEvent: CloverDeviceEvent) {
        debugPrint("END -> \(deviceEvent.eventState ?? "UNK"):\(deviceEvent.message ?? "")")
        dispatch_async(dispatch_get_main_queue()){
            if let uiView = self.uiAlertController {
//                self.uiAlertController = nil
                if self.lastDeviceEvent?.eventState == deviceEvent.eventState { // this check is because the events aren't guaranteed to be in order. could be START(A), START(B), END(A), END(B)
                    uiView.dismissViewControllerAnimated(false, completion: {
                        self.uiAlertController = nil
                    })
                    self.lastDeviceEvent = nil;
                }
                else {
                    // it should already have been dismissed
                }
            } else {
                self.lastDeviceEvent = nil
            }
        }
    }
    
    var longPressAlert:UILongPressGestureRecognizer?
    
    public func onDeviceActivityStart(_ deviceEvent: CloverDeviceEvent) {
        debugPrint("START -> \(deviceEvent.eventState ?? "UNK"):\(deviceEvent.message ?? "")")
        dispatch_async(dispatch_get_main_queue()){
            if let previousUIView = self.uiAlertController,
                let _ = self.viewController?.presentedViewController as? UIAlertController {
                
                debugPrint("Need to dismiss old controller")
                previousUIView.dismissViewControllerAnimated(false, completion: {
                    self.uiAlertController = nil
                    debugPrint("calling async on dismiss")
                    self.onDeviceActivityStart(deviceEvent)
                })
                
            } else {
                debugPrint("show new options")
                self.lastDeviceEvent = deviceEvent
                
                if self.longPressAlert == nil {
                    self.longPressAlert = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAlert(_:)))
                }
                
                
                let uiac = UIAlertController(title: "", message: deviceEvent.message ?? "", preferredStyle: .Alert)
                self.uiAlertController = uiac
                
                var addedOptions = false
                if let inputOptions = deviceEvent.inputOptions {
                    for var inputOpt in inputOptions {
                        addedOptions = true
                        self.uiAlertController?.addAction(UIAlertAction(title: inputOpt.description, style: .Default, handler: { (aa:UIAlertAction) in
                            self.uiAlertController = nil
                            self.cloverConnector?.invokeInputOption(inputOpt)
                            // waiting for device activity ended event to dismiss the input option...
                        }))
                    }
                }
                
                // if there aren't any options, then long pressing the message should make it go away...
                if !addedOptions {
                    let touchView = UIView(frame:uiac.view.frame)
                    touchView.userInteractionEnabled = true
                    uiac.view.addSubview(touchView)
                    touchView.addGestureRecognizer(self.longPressAlert!)
                }
                
                self.viewController?.presentViewController(uiac, animated: false, completion: {
                    debugPrint("done showing...")
                })
                
            }
        }

    }
    
    @objc
    private func longPressAlert(sender:UILongPressGestureRecognizer) {
        if sender.state == .Began {
            
            if let uiac = self.uiAlertController {
                dispatch_async(dispatch_get_main_queue()){
                    uiac.dismissViewControllerAnimated(false, completion: {
                        if let lpa = self.longPressAlert {
                            uiac.view.removeGestureRecognizer(lpa)
                        }
                    })
                }
            }
        }
    }
    
    
    public func onDeviceError(_ deviceErrorEvent: CloverDeviceErrorEvent) {
        dispatch_async(dispatch_get_main_queue()){
            let uiac = UIAlertController(title: deviceErrorEvent.errorType.rawValue, message: deviceErrorEvent.message, preferredStyle: .Alert)
            self.uiAlertController = uiac
            self.viewController?.presentViewController(uiac, animated: false, completion: {})
            self.uiAlertController?.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (aa:UIAlertAction) in
                self.uiAlertController?.dismissViewControllerAnimated(false, completion: {})
            }))
        }
    }

    public func onDeviceConnected() {
        ready = false // the device is connected, but not ready to communicate
    }
    
    public func onDeviceDisconnected() {
        if ready {
            showMessage("Disconnected", duration: 2)
        }
        ready = false
    }
    
    public func onTipAdded(_ message: TipAddedMessage) {
        showMessage("Tip Added: \(CurrencyUtils.IntToFormat(message.tipAmount ?? 0) ?? CurrencyUtils.IntToFormat(0)!)", duration: 1)
    }
    
    public func onDeviceReady(_ merchantInfo: MerchantInfo) {
        if !ready { // only catch changes to ready, not other calls to onDeviceReady
            showMessage("Ready", duration: 1)
            dispatch_async(dispatch_get_main_queue()){
                if let _ = self.viewController as? ViewController {
                    self.viewController?.performSegueWithIdentifier("ShowTabs", sender: self)
                }
            }
            ready = true
        }
    }
    
    
    public func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
        if let payment = request.payment {
            let lastChallenge = request.challenges!.last!
            for var challenge in request.challenges! {
                
                self.paymentConfirmDel = PaymentConfirmation(cloverConnector: self.cloverConnector!, payment:request.payment!, challenge: challenge, isLastChallenge: lastChallenge === challenge)
                let alert = UIAlertView(title: nil, message: "Verify Payment", delegate: self.paymentConfirmDel, cancelButtonTitle: nil);
                
                alert.addButtonWithTitle("Accept")
                alert.addButtonWithTitle("Reject")
                
                dispatch_async(dispatch_get_main_queue()){
                    if let alertController = self.uiAlertController {
                        alertController.dismissViewControllerAnimated(false, completion: {
                            self.uiAlertController = nil
                        })
                    }
                    alert.show()
                }

            }
            
        } else {
            showMessage("No payment in request..")
        }
        
    }
    
    public func onRefundPaymentResponse(_ refundPaymentResponse: RefundPaymentResponse) {
        if refundPaymentResponse.success {
            showMessage("Refund successful")
            for var o in getStore()?.orders ?? [] {
                for var p in (o as! POSOrder).payments {
                    if p.paymentId == refundPaymentResponse.paymentId {
                        (p as! POSPayment).status = .REFUNDED
                        let refund = POSRefund(refundId: (refundPaymentResponse.refund?.id)!, paymentId: refundPaymentResponse.paymentId!, orderID: refundPaymentResponse.orderId!, employeeId: "DFLTEMPLE", amount: (refundPaymentResponse.refund?.amount)!)
                        getStore()?.addRefundToOrder(refund, order: o as! POSOrder)
                        return
                    }
                }
            }
        } else {
            showMessage("Refund failed.")
        }
    }
    
    public func onPrintPaymentReceipt(_ printPaymentReceiptMessage: PrintPaymentReceiptMessage) {
        showMessage("Print Payment Receipt: \(formatCurrency(printPaymentReceiptMessage.payment?.amount))")
    }
    
    public func onPrintRefundPaymentReceipt(_ printRefundPaymentReceiptMessage: PrintRefundPaymentReceiptMessage) {
        showMessage("Print Refund Payment Receipt: \(formatCurrency(printRefundPaymentReceiptMessage.refund?.amount)) of \(formatCurrency(printRefundPaymentReceiptMessage.payment?.amount))")
    }
    
    public func onPrintPaymentDeclineReceipt(_ printPaymentDeclineReceiptMessage: PrintPaymentDeclineReceiptMessage) {
        showMessage("Print Payment Declined Receipt: \(formatCurrency(printPaymentDeclineReceiptMessage.payment?.amount))")
    }
    
    public func onPrintPaymentMerchantCopyReceipt(_ printPaymentMerchantCopyReceiptMessage: PrintPaymentMerchantCopyReceiptMessage) {
        showMessage("Print Payment Merchant Copy Receipt: \(formatCurrency(printPaymentMerchantCopyReceiptMessage.payment?.amount))")
    }
    
    public func onPrintManualRefundReceipt(_ printManualRefundReceiptMessage: PrintManualRefundReceiptMessage) {
        showMessage("Print Manual Refund Receipt: \(formatCurrency(printManualRefundReceiptMessage.credit?.amount))")
    }
    
    public func onPrintManualRefundDeclineReceipt(_ printManualRefundDeclineReceiptMessage: PrintManualRefundDeclineReceiptMessage) {
        showMessage("Print Manual Refund Decline Receipt: \(formatCurrency(printManualRefundDeclineReceiptMessage.credit?.amount))")
    }
    
    private func formatCurrency(_ amount:Int?) -> String {
        return CurrencyUtils.IntToFormat(amount ?? 0) ?? CurrencyUtils.IntToFormat(0)!
    }

    public func onRetrievePendingPaymentsResponse(_ retrievePendingPaymentResponse: RetrievePendingPaymentsResponse) {
        if retrievePendingPaymentResponse.success {
            showMessage("Found \(retrievePendingPaymentResponse.pendingPayments?.count ?? -1) pending payment\(retrievePendingPaymentResponse.pendingPayments?.count != 1 ? "s" : "")")
        } else {
            showMessage("Error getting pending payments")
        }
    }
    
    public func onReadCardDataResponse(_ readCardDataResponse: ReadCardDataResponse) {
        if readCardDataResponse.success {
            showMessage("\(readCardDataResponse.cardData?.first6 ?? "______")xxxxxx\(readCardDataResponse.cardData?.last4 ?? "____")")
        } else {
            showMessage("Read Card Data Failed")
        }
        cloverConnector?.showWelcomeScreen()
    }
    
    public func onCustomActivityResponse(customActivityResponse: CustomActivityResponse) {
        if customActivityResponse.success {
            showMessage("\(customActivityResponse.payload ?? "Done")")
        } else {
            showMessage("Custom activity canceled")
        }
    }
    
    public func onResetDeviceResponse(response: ResetDeviceResponse) {
        if response.success {
            showMessage("Device reset: \(response.state)")
        } else {
            showMessage("Device reset failed!")
        }
    }
    
    public func onMessageFromActivity(response: MessageFromActivity) {
        showMessage("from \(response.action ?? "<nil action>"), got: \(response.payload ?? "<nil payload>")")
    }
    
    public func onRetrievePaymentResponse(response: RetrievePaymentResponse) {
        switch response.queryStatus {
        case .FOUND:
            if let st = response.payment?.cardTransaction?.state {
                showMessage("payment found for: \(response.externalPaymentId ?? "unk"). status: \(st)")
            } else {
                showMessage("payment found for: \(response.externalPaymentId ?? "unk"). status: UNKNOWN")
            }
        case .NOT_FOUND:
            showMessage("payment not found for: \(response.externalPaymentId ?? "unk")")
        case .IN_PROGRESS:
            showMessage("payment in process: \(response.externalPaymentId ?? "unk")")
        }
    }
    
    public func onRetrieveDeviceStatusResponse(_ response: RetrieveDeviceStatusResponse) {
        if response.state != .WAITING_FOR_POS {
            showMessage("Device is currently: \(response.state.rawValue)")
        } else {
            debugPrint("Device is currently: \(response.state.rawValue)")
        }
    }
    
    public func onPairingCode(_ pairingCode:String) {
        dispatch_async(dispatch_get_main_queue()){
            if let previousUIView = self.uiAlertController {
                previousUIView.dismissViewControllerAnimated(false, completion: {})
            }
            let uiac = UIAlertController(title: nil, message: "Enter code: \(pairingCode)", preferredStyle: .Alert)
            
            self.uiAlertController = uiac
            self.viewController?.presentViewController(uiac, animated: true, completion: {})
        }
    }
    
    public func onPairingSuccess(_ pairingAuthToken:String) {
        if let previousUIView = self.uiAlertController {
            dispatch_async(dispatch_get_main_queue()){
                previousUIView.dismissViewControllerAnimated(false, completion: {})
            }
        }
    }
    
    class PaymentConfirmation : NSObject, UIAlertViewDelegate
    {
        private var last:Bool = false;
        private var cloverConnector:ICloverConnector
        private var payment:CLVModels.Payments.Payment
        private var challenge:Challenge
        
        init(cloverConnector:ICloverConnector, payment:CLVModels.Payments.Payment, challenge: Challenge, isLastChallenge: Bool) {
            self.last = isLastChallenge
            self.cloverConnector = cloverConnector
            self.payment = payment
            self.challenge = challenge
        }
        
        public func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
            if(buttonIndex == 1) // reject
            {
                cloverConnector.rejectPayment(payment, challenge: challenge)
            }
            else if(buttonIndex == 0 && last)
            {
                cloverConnector.acceptPayment(payment)
            }
        }
        
    }
}
