//
//  TestCloverConnectorListener.swift
//  CloverConnector
//
//  
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import CloverConnector
import UIKit

class TestCloverConnectorListener : DefaultCloverConnectorListener {
    
    public var viewController:TestViewController?
    private var lastPAResponse:PreAuthResponse?
    private var lastTARequest:TipAdjustAuthRequest?
    
    public init(cloverConnector:CloverConnector) {
        super.init(cloverConnector:cloverConnector)
    }
    
    override func onDeviceActivityStart(_ deviceEvent: CloverDeviceEvent) {
        viewController?.uiStateLabel.text = deviceEvent.message
    }
    
    
    
    override func onSaleResponse(_ response: SaleResponse) {
        if response.success {
            //showMessage("Success!")
            viewController?.label.text = "Sale Success!"
            if let orderId = response.payment?.order?.id,
                let paymentId = response.payment?.id {
                promptForRefundAndVoid(orderId, paymentId:paymentId)
            }
            
        } else {
            showMessage("Sale Failed!")
            viewController?.label.text = "Sale Failed!"
        }
    }
    
    override func onTipAdjustAuthResponse(_ tipAdjustAuthResponse: TipAdjustAuthResponse) {
        if tipAdjustAuthResponse.success {
            viewController?.label.text = "\(tipAdjustAuthResponse.tipAmount!) Tip Applied Successfully"
            if let lastTA = lastTARequest {
                promptForRefundAndVoid(lastTA.orderId, paymentId: lastTA.paymentId)
            }
        } else {
            viewController?.label.text = "Tip Failed"
        }
    }
    
    override func onAuthResponse(_ authResponse: AuthResponse) {
        if authResponse.success {
            viewController?.label.text = "Auth Success!"
            if let orderId = authResponse.payment?.order?.id,
                let paymentId = authResponse.payment?.id
            {
                promptForTip(orderId, paymentId: paymentId)
            }
        } else {
            showMessage("Auth Failed!: \(authResponse.result.rawValue): \(authResponse.message)")
        }
    }
    
    override func onPreAuthResponse(_ preAuthResponse: PreAuthResponse) {
        if preAuthResponse.success {
            viewController?.label.text = "PreAuth Success!"
            lastPAResponse = preAuthResponse // so we can do tip, refund and void after capture..
            
            let alert = UIAlertController(title: nil, message: "Would you like to capture for $25.00?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                let cpar = CapturePreAuthRequest(amount: 2500, paymentId: (preAuthResponse.payment?.id)!)
                self.cloverConnector?.capturePreAuth(cpar)
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: {(action:UIAlertAction) in
                
            }))

            self.viewController?.showViewController(alert, sender: self.viewController!)
        } else {
            
        }
    }
    
    override func onRefundPaymentResponse(_ response: RefundPaymentResponse) {
        if response.success {
            viewController?.label.text = "Refund successful!"
            showMessage("Refund successful")
        } else {
            viewController?.label.text = "Refund failed"
            showMessage("Refund failed")
        }
    }
    
    override func onCapturePreAuthResponse(_ capturePreAuthResponse: CapturePreAuthResponse) {
        if capturePreAuthResponse.success {
            viewController?.label.text = "PreAuth Captured!"
            if let orderId = lastPAResponse?.payment?.order?.id,
                let paymentId = capturePreAuthResponse.paymentId {
                promptForTip(orderId, paymentId: paymentId)
            }
            
        } else {
            viewController?.label.text = "PreAuth Capture Failed!"
            showMessage("Capture PreAuth Failed!: \(capturePreAuthResponse.result.rawValue): \(capturePreAuthResponse.message)")
        }
    }
    
    override func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
        if let payment = request.payment {
            let lastChallenge = request.challenges!.last!
            for var challenge in request.challenges! {
                
                let alert = UIAlertController(title: "Verify Payment", message: challenge.message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                    // do nothing, unless this is the last challenge
                    
                    if lastChallenge === challenge {
                        self.cloverConnector?.acceptPayment(payment)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Reject", style: UIAlertActionStyle.Cancel, handler: {(action:UIAlertAction) in
                    self.cloverConnector?.rejectPayment(payment, challenge: challenge)
                }))
                self.viewController?.showViewController(alert, sender: self.viewController)

            }

        } else {
            showMessage("No payment in request..")
        }
        
    }
    
    override func onVoidPaymentResponse(_ voidPaymentResponse: VoidPaymentResponse) {
        if voidPaymentResponse.success {
            viewController?.label.text = "Success: Payment Voided!"
        } else {
            viewController?.label.text = "Payment Void Failed!"
        }
    }
    
    override func onVerifySignatureRequest(_ signatureVerifyRequest: VerifySignatureRequest) {
        viewController?.label.text = "Auto-Accepting Signature"
        
        cloverConnector?.acceptSignature(signatureVerifyRequest)
    }
    
    override func onRetrievePendingPaymentsResponse(_ retrievePendingPaymentResponse: RetrievePendingPaymentsResponse) {
        showMessage(retrievePendingPaymentResponse.success ? "\(retrievePendingPaymentResponse.pendingPayments?.count) Pending" : "Failed to get list")
    }
    
    private func showMessage(_ message:String?) {
        let alertView:UIAlertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
        alertView.show()
        performSelector(#selector(dismissMessage), withObject: alertView, afterDelay: 3)
    }
    
    @objc private func dismissMessage(_ view:UIAlertView) {
        view.dismissWithClickedButtonIndex(-1, animated: true);
    }
    
    private func promptForTip(orderId:String, paymentId:String) {
        let alert = UIAlertController(title: nil, message: "Would you like to add a $3.00 tip?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
            let tar = TipAdjustAuthRequest(orderId: orderId, paymentId: paymentId, tipAmount: 300)
            self.lastTARequest = tar // so we can do refund and void later
            self.cloverConnector?.tipAdjustAuth(tar)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: {(action:UIAlertAction) in
            self.promptForRefundAndVoid(orderId, paymentId:paymentId)
        }))
        self.viewController?.showViewController(alert, sender: self.viewController!)
    }

    private func promptForRefundAndVoid(orderId:String, paymentId:String) {
        
        let alert = UIAlertController(title: nil, message: "Would you like to refund the payment?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Full", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
            let rpr = RefundPaymentRequest(orderId: orderId, paymentId: paymentId, fullRefund: true)
            self.cloverConnector?.refundPayment(rpr)
            return
        }))
        alert.addAction(UIAlertAction(title: "Partial", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
            let rpr = RefundPaymentRequest(orderId: orderId, paymentId: paymentId, amount: 500)
            self.cloverConnector?.refundPayment(rpr)
            return
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: {(action:UIAlertAction) in
            self.promptForVoid(orderId, paymentId:paymentId)
            return
        }))

        viewController?.showViewController(alert, sender: viewController!)

    }
    
    private func promptForVoid(orderId:String, paymentId:String) {
        let voidAlert = UIAlertController(title: nil, message: "Would you like to void the payment?", preferredStyle: UIAlertControllerStyle.Alert)
        voidAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
            let vpr = VoidPaymentRequest(orderId: orderId, paymentId: paymentId, voidReason: .USER_CANCEL)
            self.cloverConnector?.voidPayment(vpr)
            
        }))
        voidAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: {(action:UIAlertAction) in
            return
        }))
        self.viewController?.showViewController(voidAlert, sender: self.viewController!)
    }
    
    
}

class AlertViewHandler: NSObject, UIAlertViewDelegate {
    typealias ButtonCallback = (buttonIndex: Int)->()
    var onClick: ButtonCallback?
    
    init(onClick: ButtonCallback?) {
        super.init()
        self.onClick = onClick
    }
    
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        self.onClick?(buttonIndex: buttonIndex)
    }
    
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.onClick?(buttonIndex: buttonIndex)
    }
}
