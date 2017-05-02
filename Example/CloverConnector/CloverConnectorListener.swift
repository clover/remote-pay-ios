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
    var cloverConnector:ICloverConnector?
    
    public var parentViewController:UIViewController?
    private var uiView:UIAlertView?
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
    
    @objc private func dismissMessage(_ view:UIAlertView) {
        view.dismissWithClickedButtonIndex( -1, animated: true);
    }
    
    private func showMessage(_ message:String, duration:Int = 3) {

        dispatch_async(dispatch_get_main_queue()){
            let alertView:UIAlertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
            alertView.show()
            self.performSelector(#selector(self.dismissMessage), withObject: alertView, afterDelay: NSTimeInterval(duration))
        }

    }
    
    /*
     * Response to a sale request.
     */
    public func  onSaleResponse ( _ response:SaleResponse ) -> Void {
        if response.success {
            if let store = getStore() {
                if let payment = response.payment,
                    let order = store.currentOrder {
                    let tipAmount = payment.tipAmount ?? 0
                    let cashback = payment.cashbackAmount ?? 0
                    let posPayment:POSPayment = POSPayment(paymentId: payment.id!, externalPaymentId: payment.externalPaymentId, orderId: payment.order!.id!, employeeId: "DFLTEMPLYEE", amount: payment.amount!, tipAmount: tipAmount, cashbackAmount: cashback)
                    
                    posPayment.status = response.isSale ? PaymentStatus.PAID : (response.isAuth ? PaymentStatus.AUTHORIZED : (response.isPreAuth ? PaymentStatus.PREAUTHORIZED : PaymentStatus.UNKNOWN))
                    
                    if response.isSale || response.isAuth {
                        store.addPaymentToOrder(posPayment, order: order)
                        if response.isSale {
                            showMessage("Sale successfully processed")
                        } else if response.isAuth {
                            showMessage("Auth successfully processed")
                        }
                        store.newOrder()
                        cloverConnector?.showWelcomeScreen()
                    } else if response.isPreAuth {
                        store.addPreAuth(posPayment)
                        showMessage("Pre-Auth successful")
                    }
                }
            }
        } else {
            if response.result == .CANCEL {
                showMessage("User canceled the transaction")
            } else if response.result == .FAIL {
                showMessage("Tx Failed")
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
                showMessage("User canceled the transaction")
            } else if authResponse.result == .FAIL {
                showMessage("Tx Failed")
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
            if let store = getStore() {
                if let payment = preAuthResponse.payment {
                    let posPayment:POSPayment = POSPayment(paymentId: payment.id!, externalPaymentId: payment.externalPaymentId, orderId: payment.order!.id!, employeeId: "DFLTEMPLYEE", amount: payment.amount!, tipAmount: payment.tipAmount ?? 0, cashbackAmount: payment.cashbackAmount ?? 0)
                    store.addPreAuth(posPayment)
                }
            }
        } else {
            
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
            if let view = self.uiView {
                view.dismissWithClickedButtonIndex(0, animated: false)
            }
            if let ivc = self.parentViewController {
                (ivc as? RegisterViewController)!.verifySignature(signatureVerifyRequest);
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
        if let uiView = uiView {
            if self.lastDeviceEvent?.eventState == deviceEvent.eventState { // this check is because the events aren't guaranteed to be in order. could be START(A), START(B), END(A), END(B)
                dispatch_async(dispatch_get_main_queue()){
                    uiView.dismissWithClickedButtonIndex( 0, animated: true)
                }
                self.lastDeviceEvent = nil;
            }
            else {
                // it should already have been dismissed
            }
        }
    }
    
    public func onDeviceActivityStart(_ deviceEvent: CloverDeviceEvent) {
        if let previousUIView = self.uiView {
            dispatch_async(dispatch_get_main_queue()){
                previousUIView.dismissWithClickedButtonIndex( 0, animated:false)
            }
        }
        self.lastDeviceEvent = deviceEvent

        var uInfo = [String:String]()
        
        if let inputOptions = deviceEvent.inputOptions {
            for var io in inputOptions {
                if let kp = io.keyPress {
                    uInfo[io.description] = kp.rawValue
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue()){
            self.uiView = UIAlertView(title:nil, message: deviceEvent.message!, delegate: self, cancelButtonTitle: nil)
            for var key in (uInfo.keys) {
                self.uiView!.addButtonWithTitle( key)
            }
            self.uiView!.show()
        }
    }
    
    public func onDeviceError(_ deviceErrorEvent: CloverDeviceErrorEvent) {
        dispatch_async(dispatch_get_main_queue()){
            UIAlertView(title:deviceErrorEvent.errorType.rawValue, message: deviceErrorEvent.message, delegate: self, cancelButtonTitle: "Cancel")
            self.uiView!.show()
        }
    }

    public func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {

        if let lastDeviceEvent = lastDeviceEvent,
            let inputOptions = lastDeviceEvent.inputOptions {
            for var io in inputOptions {
                if io.description == alertView.buttonTitleAtIndex(buttonIndex)! {
                    cloverConnector!.invokeInputOption(io)
                    break
                }
            }
        }
    }

    public func onDeviceConnected() {
        ready = false
    }
    
    public func onDeviceDisconnected() {
        if ready {
            showMessage("Disconnected", duration: 2)
        }
        ready = false
    }
    
    public func onTipAdded(_ message: TipAddedMessage) {
        
    }
    
    public func onDeviceReady(_ merchantInfo: MerchantInfo) {
        if !ready {
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
                    if let view = self.uiView {
                        view.dismissWithClickedButtonIndex(0, animated: false)
                    }
                    alert.show()
                }

            }
            
        } else {
            showMessage("No payment in request..")
        }
        
    }
    
    public func onRefundPaymentResponse(_ refundPaymentResponse: RefundPaymentResponse) {
        
    }
    
    public func onPrintPaymentReceipt(_ printPaymentReceiptMessage: PrintPaymentReceiptMessage) {
        
    }
    
    public func onPrintRefundPaymentReceipt(_ printRefundPaymentReceiptMessage: PrintRefundPaymentReceiptMessage) {
        
    }
    
    public func onPrintPaymentDeclineReceipt(_ printPaymentDeclineReceiptMessage: PrintPaymentDeclineReceiptMessage) {
        
    }
    
    public func onPrintPaymentMerchantCopyReceipt(_ printPaymentMerchantCopyReceiptMessage: PrintPaymentMerchantCopyReceiptMessage) {
        
    }
    
    public func onPrintManualRefundReceipt(_ printManualRefundReceiptMessage: PrintManualRefundReceiptMessage) {
        
    }
    
    public func onPrintManualRefundDeclineReceipt(_ printManualRefundDeclineReceiptMessage: PrintManualRefundDeclineReceiptMessage) {
        
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
    
    public func onPairingCode(_ pairingCode:String) {
        dispatch_async(dispatch_get_main_queue()){
            if let previousUIView = self.uiView {
                previousUIView.dismissWithClickedButtonIndex(0, animated:false)
            }
            self.uiView = UIAlertView(title: nil, message: "Enter code: \(pairingCode)", delegate: self, cancelButtonTitle: nil)
            self.uiView?.show()
        }
    }
    
    public func onPairingSuccess(_ pairingAuthToken:String) {
        if let previousUIView = self.uiView {
            dispatch_async(dispatch_get_main_queue()){
                previousUIView.dismissWithClickedButtonIndex(-1, animated:false)
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
