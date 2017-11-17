//
//  TestCloverConnectorListener.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import CloverConnector
import UIKit

class TestCloverConnectorListener : DefaultCloverConnectorListener {
    
    public var viewController:TestViewController?
    fileprivate var lastPAResponse:PreAuthResponse?
    fileprivate var lastTARequest:TipAdjustAuthRequest?
    
    public init(cloverConnector:ICloverConnector) {
        super.init(cloverConnector:cloverConnector)
    }
    
    override func onDeviceActivityStart(_ deviceEvent: CloverDeviceEvent) {
        viewController?.uiStateLabel.text = deviceEvent.message
    }
    
    
    
    override func onSaleResponse(_ response: SaleResponse) {
        DispatchQueue.main.async { [weak self] in
            if response.success {
                self?.viewController?.label.text = "Sale Success!"
                if let orderId = response.payment?.order?.id,
                    let paymentId = response.payment?.id {
                    self?.promptForRefundAndVoid(orderId, paymentId:paymentId)
                }
                
            } else {
                self?.showMessage("Sale Failed!")
                self?.viewController?.label.text = "Sale Failed!"
            }
        }
    }
    
    override func onTipAdjustAuthResponse(_ tipAdjustAuthResponse: TipAdjustAuthResponse) {
        DispatchQueue.main.async { [weak self] in
            if tipAdjustAuthResponse.success && tipAdjustAuthResponse.tipAmount != nil {
                self?.viewController?.label.text = String(tipAdjustAuthResponse.tipAmount!) + " Tip Applied Successfully"
                if let lastTA = self?.lastTARequest {
                    self?.promptForRefundAndVoid(lastTA.orderId, paymentId: lastTA.paymentId)
                }
            } else {
                self?.viewController?.label.text = "Tip Failed"
            }
        }
    }
    
    override func onAuthResponse(_ authResponse: AuthResponse) {
        DispatchQueue.main.async { [weak self] in
            if authResponse.success {
                self?.viewController?.label.text = "Auth Success!"
                if let orderId = authResponse.payment?.order?.id,
                    let paymentId = authResponse.payment?.id
                {
                    self?.promptForTip(orderId, paymentId: paymentId)
                }
            } else {
                self?.showMessage("Auth Failed!: " + authResponse.result.rawValue + ":" + (authResponse.message ?? ""))
            }
        }
    }
    
    override func onPreAuthResponse(_ preAuthResponse: PreAuthResponse) {
        if preAuthResponse.success && preAuthResponse.payment?.id != nil {
            viewController?.label.text = "PreAuth Success!"
            lastPAResponse = preAuthResponse // so we can do tip, refund and void after capture..
            
            let alert = UIAlertController(title: nil, message: "Would you like to capture for $25.00?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                let cpar = CapturePreAuthRequest(amount: 2500, paymentId: (preAuthResponse.payment?.id)!)
                self.cloverConnector?.capturePreAuth(cpar)
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: {(action:UIAlertAction) in
                
            }))

            if let viewController = self.viewController {
                viewController.show(alert, sender: viewController)
            }
        }
    }
    
    override func onRefundPaymentResponse(_ response: RefundPaymentResponse) {
        DispatchQueue.main.async { [weak self] in
            if response.success {
                self?.viewController?.label.text = "Refund successful!"
                self?.showMessage("Refund successful")
            } else {
                self?.viewController?.label.text = "Refund failed"
                self?.showMessage("Refund failed")
            }
        }
    }
    
    override func onCapturePreAuthResponse(_ capturePreAuthResponse: CapturePreAuthResponse) {
        DispatchQueue.main.async { [weak self] in
            if capturePreAuthResponse.success {
                self?.viewController?.label.text = "PreAuth Captured!"
                if let orderId = self?.lastPAResponse?.payment?.order?.id,
                    let paymentId = capturePreAuthResponse.paymentId {
                    self?.promptForTip(orderId, paymentId: paymentId)
                }
                
            } else {
                self?.viewController?.label.text = "PreAuth Capture Failed!"
                self?.showMessage("Capture PreAuth Failed!: " + capturePreAuthResponse.result.rawValue + ": " + (capturePreAuthResponse.message ?? ""))
            }
        }
    }
    
    override func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
        DispatchQueue.main.async { [weak self] in
            if let payment = request.payment,
                let challenges = request.challenges,
                let lastChallenge = request.challenges?.last {
                for challenge in challenges {
                    
                    let alert = UIAlertController(title: "Verify Payment", message: challenge.message, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                        // do nothing, unless this is the last challenge
                        
                        if lastChallenge === challenge {
                            self?.cloverConnector?.acceptPayment(payment)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Reject", style: UIAlertActionStyle.cancel, handler: {(action:UIAlertAction) in
                        self?.cloverConnector?.rejectPayment(payment, challenge: challenge)
                    }))
                    self?.viewController?.present(alert, animated: true, completion: nil)
                }
                
            } else {
                self?.showMessage("No payment in request..")
            }
        }
    }
    
    override func onVoidPaymentResponse(_ voidPaymentResponse: VoidPaymentResponse) {
        DispatchQueue.main.async { [weak self] in
            if voidPaymentResponse.success {
                self?.viewController?.label.text = "Success: Payment Voided!"
            } else {
                self?.viewController?.label.text = "Payment Void Failed!"
            }
        }
    }
    
    override func onVerifySignatureRequest(_ signatureVerifyRequest: VerifySignatureRequest) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.label.text = "Auto-Accepting Signature"
            self?.cloverConnector?.acceptSignature(signatureVerifyRequest)
        }
    }
    
    override func onRetrievePendingPaymentsResponse(_ retrievePendingPaymentResponse: RetrievePendingPaymentsResponse) {
        showMessage(retrievePendingPaymentResponse.success ? String(describing: retrievePendingPaymentResponse.pendingPayments?.count) + " Pending" : "Failed to get list")
    }
    
    fileprivate func showMessage(_ message:String?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.present(alert, animated: true, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: { [weak self] in
            self?.dismissMessage(alert)
        })
    }
    
    fileprivate func dismissMessage(_ view:UIAlertController) {
        view.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func promptForTip(_ orderId:String, paymentId:String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: nil, message: "Would you like to add a $3.00 tip?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { [weak self] (action:UIAlertAction) in
                let tar = TipAdjustAuthRequest(orderId: orderId, paymentId: paymentId, tipAmount: 300)
                self?.lastTARequest = tar // so we can do refund and void later
                self?.cloverConnector?.tipAdjustAuth(tar)
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: { [weak self] (action:UIAlertAction) in
                self?.promptForRefundAndVoid(orderId, paymentId:paymentId)
            }))
            self?.viewController?.present(alert, animated: true, completion: nil)
        }
    }

    fileprivate func promptForRefundAndVoid(_ orderId:String, paymentId:String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: nil, message: "Would you like to refund the payment?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Full", style: UIAlertActionStyle.default, handler: { [weak self] (action:UIAlertAction) in
                let rpr = RefundPaymentRequest(orderId: orderId, paymentId: paymentId, fullRefund: true)
                self?.cloverConnector?.refundPayment(rpr)
                return
            }))
            alert.addAction(UIAlertAction(title: "Partial", style: UIAlertActionStyle.default, handler: { [weak self] (action:UIAlertAction) in
                let rpr = RefundPaymentRequest(orderId: orderId, paymentId: paymentId, amount: 500)
                self?.cloverConnector?.refundPayment(rpr)
                return
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: { [weak self] (action:UIAlertAction) in
                self?.promptForVoid(orderId, paymentId:paymentId)
                return
            }))
            
            self?.viewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func promptForVoid(_ orderId:String, paymentId:String) {
        DispatchQueue.main.async { [weak self] in
            let voidAlert = UIAlertController(title: nil, message: "Would you like to void the payment?", preferredStyle: UIAlertControllerStyle.alert)
            voidAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { [weak self] (action:UIAlertAction) in
                let vpr = VoidPaymentRequest(orderId: orderId, paymentId: paymentId, voidReason: .USER_CANCEL)
                self?.cloverConnector?.voidPayment(vpr)
                
            }))
            voidAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            self?.viewController?.present(voidAlert, animated: true, completion: nil)
        }
    }
}


