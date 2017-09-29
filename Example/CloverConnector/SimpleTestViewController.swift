//
//  SimpleTestViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector


class SimpleTestViewController : UITableViewController {
    @IBOutlet weak var allowOffline: UISegmentedControl!
    @IBOutlet weak var acceptOfflineWOPrompt: UISegmentedControl!
    @IBOutlet weak var autoAcceptPayments: UISegmentedControl!
    @IBOutlet weak var autoAcceptSigs: UISegmentedControl!
    @IBOutlet weak var cardNotPresent: UISegmentedControl!
    @IBOutlet weak var disableCashback: UISegmentedControl!
    @IBOutlet weak var disableDuplicateChecking: UISegmentedControl!
    @IBOutlet weak var disablePrinting: UISegmentedControl!
    @IBOutlet weak var disableReceiptScreen: UISegmentedControl!
    @IBOutlet weak var disableRestartOnFail: UISegmentedControl!
    @IBOutlet weak var sigLocation: UISegmentedControl!
    @IBOutlet weak var tipModeButtons: UISegmentedControl!
    @IBOutlet weak var swipeSwitch: UISwitch!
    @IBOutlet weak var chipSwitch: UISwitch!
    @IBOutlet weak var nfcSwitch: UISwitch!
    @IBOutlet weak var manualSwitch: UISwitch!
    @IBOutlet weak var forceOfflineSwitch: UISegmentedControl!
    
    @IBOutlet weak var txAmount: UITextField!
    @IBOutlet weak var saleTipAmount: UITextField!
    var currentExecutor:Executor?
    
    private var cloverConnector:ICloverConnector? {
        get {
            return (UIApplication.sharedApplication().delegate as? AppDelegate)?.cloverConnector
        }
    }
    
    private var store:POSStore? {
        get {
            return (UIApplication.sharedApplication().delegate as? AppDelegate)?.store
        }
    }
    
    private var _id = 0
    private var id : Int {
        get {
            _id = _id+1
            return _id
        }
    }
    
    @IBAction func processTXLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            // vault the card...
            let vce = VaultCardExecutor(cloverConnector: cloverConnector!, payment: nil)
            vce.after = {
                card in
                dispatch_async(dispatch_get_main_queue()) {
                    self.processTx(card)
                }
            }
            vce.run()
        }
        
    }
    
    @IBAction func onTipModeChanged(sender: UISegmentedControl) {
        
    }
    
    @IBAction func processTxClicked(sender: UIButton) {
        processTx(nil)
    }
    
    func updateUIFromSettings() {
        if let tx = store?.transactionSettings, let cloverConnector = self.cloverConnector {
            allowOffline.selectedSegmentIndex = tx.allowOfflinePayment == nil ? 0 : (tx.allowOfflinePayment! ? 1 : 2)
            acceptOfflineWOPrompt.selectedSegmentIndex = (tx.approveOfflinePaymentWithoutPrompt == nil ? 0 : (tx.approveOfflinePaymentWithoutPrompt! ? 1 : 2))
            autoAcceptPayments.selectedSegmentIndex = tx.autoAcceptPaymentConfirmations == nil ? 0 : (tx.autoAcceptPaymentConfirmations! ? 1 : 2)
            autoAcceptSigs.selectedSegmentIndex = tx.autoAcceptSignature == nil ? 0 : (tx.autoAcceptSignature! ? 1 : 2)
            disablePrinting.selectedSegmentIndex = tx.cloverShouldHandleReceipts == nil ? 0 : (tx.cloverShouldHandleReceipts! ? 1 : 2)
            disableCashback.selectedSegmentIndex = tx.disableCashBack == nil ? 0 : (tx.disableCashBack! ? 1 : 2)
            disableDuplicateChecking.selectedSegmentIndex = tx.disableDuplicateCheck == nil ? 0 : (tx.disableDuplicateCheck! ? 1 : 2)
            disableReceiptScreen.selectedSegmentIndex = tx.disableReceiptSelection == nil ? 0 : (tx.disableReceiptSelection! ? 1 : 2)
            disableRestartOnFail.selectedSegmentIndex = tx.disableRestartTransactionOnFailure == nil ? 0 : (tx.disableRestartTransactionOnFailure! ? 1 : 2)
            forceOfflineSwitch.selectedSegmentIndex = tx.forceOfflinePayment == nil ? 0 : (tx.forceOfflinePayment! ? 1 : 2)
            manualSwitch.on = ((tx.cardEntryMethods ?? 0) & cloverConnector.CARD_ENTRY_METHOD_MANUAL) == cloverConnector.CARD_ENTRY_METHOD_MANUAL
            swipeSwitch.on = ((tx.cardEntryMethods ?? 0) & cloverConnector.CARD_ENTRY_METHOD_MAG_STRIPE) == cloverConnector.CARD_ENTRY_METHOD_MAG_STRIPE
            chipSwitch.on = ((tx.cardEntryMethods ?? 0) & cloverConnector.CARD_ENTRY_METHOD_ICC_CONTACT) == cloverConnector.CARD_ENTRY_METHOD_ICC_CONTACT
            nfcSwitch.on = ((tx.cardEntryMethods ?? 0) & cloverConnector.CARD_ENTRY_METHOD_NFC_CONTACTLESS) == cloverConnector.CARD_ENTRY_METHOD_NFC_CONTACTLESS
            
            if let store = store {
                cardNotPresent.selectedSegmentIndex = store.cardNotPresent == nil ? 0 : (store.cardNotPresent! ? 1 : 2)
            }
            
            if tx.signatureEntryLocation == CLVModels.Payments.DataEntryLocation.ON_SCREEN {
                sigLocation.selectedSegmentIndex = 1
            } else if tx.signatureEntryLocation == CLVModels.Payments.DataEntryLocation.ON_PAPER {
                sigLocation.selectedSegmentIndex = 2
            } else if tx.signatureEntryLocation == CLVModels.Payments.DataEntryLocation.NONE {
                sigLocation.selectedSegmentIndex = 3
            } else {
                sigLocation.selectedSegmentIndex = 0
            }
            
            if tx.tipMode == CLVModels.Payments.TipMode.ON_SCREEN_BEFORE_PAYMENT {
                tipModeButtons.selectedSegmentIndex = 1
            } else if tx.tipMode == CLVModels.Payments.TipMode.TIP_PROVIDED {
                tipModeButtons.selectedSegmentIndex = 2
            } else if tx.tipMode == CLVModels.Payments.TipMode.NO_TIP {
                tipModeButtons.selectedSegmentIndex = 3
            } else {
                tipModeButtons.selectedSegmentIndex = 0
            }
            
            
        }
    }
    
    @IBAction func loadSettingsFromUI(_ sender:AnyObject) {
        guard let cloverConnector = cloverConnector else { return }
        
//        let txSettings = CLVModels.Payments.TransactionSettings()
        let txSettings = store?.transactionSettings ?? CLVModels.Payments.TransactionSettings()
        txSettings.allowOfflinePayment = allowOffline.selectedSegmentIndex == 0 ? nil : (allowOffline.selectedSegmentIndex == 1 ? true : false)
        txSettings.approveOfflinePaymentWithoutPrompt = acceptOfflineWOPrompt.selectedSegmentIndex == 0 ? nil : (acceptOfflineWOPrompt.selectedSegmentIndex == 1 ? true : false)
        txSettings.autoAcceptPaymentConfirmations = autoAcceptPayments.selectedSegmentIndex == 0 ? nil : (autoAcceptPayments.selectedSegmentIndex == 1 ? true : false)
        txSettings.autoAcceptSignature = autoAcceptSigs.selectedSegmentIndex == 0 ? nil : (autoAcceptSigs.selectedSegmentIndex == 1 ? true : false)
        txSettings.cloverShouldHandleReceipts = self.disablePrinting.selectedSegmentIndex == 0 ? nil : (self.disablePrinting.selectedSegmentIndex == 1 ? false : true)
        txSettings.disableCashBack = disableCashback.selectedSegmentIndex == 0 ? nil : (disableCashback.selectedSegmentIndex == 1 ? true : false)
        txSettings.disableDuplicateCheck = disableDuplicateChecking.selectedSegmentIndex == 0 ? nil : (disableDuplicateChecking.selectedSegmentIndex == 1 ? true : false)
        txSettings.disableReceiptSelection = disableReceiptScreen.selectedSegmentIndex == 0 ? nil : (disableReceiptScreen.selectedSegmentIndex == 1 ? true : false)
        txSettings.disableRestartTransactionOnFailure = disableRestartOnFail.selectedSegmentIndex == 0 ? nil : (disableRestartOnFail.selectedSegmentIndex == 1 ? true : false)
        txSettings.forceOfflinePayment = forceOfflineSwitch.selectedSegmentIndex == 0 ? nil : (forceOfflineSwitch.selectedSegmentIndex == 1 ? true : false)
        if let store = store {
            store.cardNotPresent = cardNotPresent.selectedSegmentIndex == 0 ? nil : (cardNotPresent.selectedSegmentIndex == 1 ? true : false)
        }
        
        var cem = 0;
        cem |= (swipeSwitch.on ? cloverConnector.CARD_ENTRY_METHOD_MAG_STRIPE : 0)
        cem |= (chipSwitch.on ? cloverConnector.CARD_ENTRY_METHOD_ICC_CONTACT : 0)
        cem |= (nfcSwitch.on ? cloverConnector.CARD_ENTRY_METHOD_NFC_CONTACTLESS : 0)
        cem |= (manualSwitch.on ? cloverConnector.CARD_ENTRY_METHOD_MANUAL : 0)
        txSettings.cardEntryMethods = cem
        
        
        switch sigLocation.selectedSegmentIndex {
            case 0: txSettings.signatureEntryLocation = nil
            case 1: txSettings.signatureEntryLocation = CLVModels.Payments.DataEntryLocation.ON_SCREEN
            case 2: txSettings.signatureEntryLocation = CLVModels.Payments.DataEntryLocation.ON_PAPER
            case 3: txSettings.signatureEntryLocation = CLVModels.Payments.DataEntryLocation.NONE
            default: txSettings.signatureEntryLocation = nil
        }
        switch tipModeButtons.selectedSegmentIndex {
            case 0: txSettings.tipMode = nil
            case 1: txSettings.tipMode = CLVModels.Payments.TipMode.ON_SCREEN_BEFORE_PAYMENT
            case 2: txSettings.tipMode = CLVModels.Payments.TipMode.TIP_PROVIDED
            case 3: txSettings.tipMode = CLVModels.Payments.TipMode.NO_TIP
            default: txSettings.tipMode = nil
        }

        self.currentExecutor = PaymentExecutor(cloverConnector: cloverConnector, payment: nil)
        
        if let pe = self.currentExecutor as? PaymentExecutor {
            pe.cardNotPresent = store?.cardNotPresent
        }
        
        if let amt = Int(txAmount.text ?? "2525") {
            (self.currentExecutor as! PaymentExecutor).amount = amt
        } else {
            (self.currentExecutor as! PaymentExecutor).amount = 2525
        }
        if let ta = saleTipAmount.text {
            if let tipAmount = Int(ta) {
                (self.currentExecutor as! PaymentExecutor).tipAmount = tipAmount
            }
        }
    }
    
    @objc func processTx(_ card:CLVModels.Payments.VaultedCard?)
    {
        if let amt = Int(txAmount.text ?? "2525") {
            (self.currentExecutor as! PaymentExecutor).amount = amt
        } else {
            (self.currentExecutor as! PaymentExecutor).amount = 2525
        }

        (self.currentExecutor as! PaymentExecutor).transactionSettings = store?.transactionSettings
        (self.currentExecutor as! PaymentExecutor).vaultedCard = card
        currentExecutor?.run()
    }
    
    
    @IBAction func resetDevice(sender: UIButton) {
        cloverConnector?.resetDevice()
    }


    func showErrorMessage(message:String) {
        var view = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: nil)
        
        dispatch_async(dispatch_get_main_queue()) {
            dispatch_after(2, dispatch_get_main_queue(), {
                view.dismissWithClickedButtonIndex(-1, animated: true)
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.currentExecutor = self.currentExecutor ?? PaymentExecutor(cloverConnector: cloverConnector!, payment: nil)
        cloverConnector?.removeCloverConnectorListener(((UIApplication.sharedApplication().delegate as? AppDelegate)?.cloverConnectorListener)!)
        cloverConnector?.removeCloverConnectorListener(((UIApplication.sharedApplication().delegate as? AppDelegate)?.testCloverConnectorListener)!)
        updateUIFromSettings()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // default back to the default controller, the other tabs can switch
        cloverConnector?.addCloverConnectorListener(((UIApplication.sharedApplication().delegate as? AppDelegate)?.cloverConnectorListener)!)
    }
    
    
    override func viewDidLoad() {
    }
}

extension SimpleTestViewController : UIAlertViewDelegate {
    func alertViewCancel(alertView: UIAlertView) {
        
    }
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        
    }
}

class Collector {
    //inputs
    var txSettings:CLVModels.Payments.TransactionSettings?
    var request:TransactionRequest?
}

class BaseExecutor : DefaultCloverConnectorListener {
    var payment:CLVModels.Payments.Payment?
    
    // run this next by default
    var executor:Executor?
    var delegate:UIAlertViewDelegate?
    
    init(cloverConnector:ICloverConnector, payment:CLVModels.Payments.Payment?, nextExecutor ex:Executor? = nil) {
        self.executor = ex
        self.payment = payment
        super.init(cloverConnector: cloverConnector)
    }
    
    override func onVerifySignatureRequest(signatureVerifyRequest: VerifySignatureRequest) {
        delegate = VerifySignatureDelegate(cloverConnector: cloverConnector!, request: signatureVerifyRequest)
        let view = UIAlertView(title: "Verify", message: "Verify Signature", delegate: delegate, cancelButtonTitle: nil)
        view.addButtonWithTitle("Accept")
        view.addButtonWithTitle("Reject")
        
        dispatch_async(dispatch_get_main_queue()) {
            view.show()
        }
    }
    
    override func onConfirmPaymentRequest(request: ConfirmPaymentRequest) {
        promptForChallenge(request, challengeIndex: 0)
    }
    
    private func promptForChallenge(request:ConfirmPaymentRequest, challengeIndex index:Int) {
        let challenge = request.challenges![index]
        delegate = ConfirmPaymentDelegate(cc: cloverConnector!, executor: self, request: request, challengeIndex: index)
        let view = UIAlertView(title: "Confirm", message: (challenge.message ?? "No Message."), delegate: delegate, cancelButtonTitle: nil)
        view.addButtonWithTitle("Accept")
        view.addButtonWithTitle("Reject")
        
        dispatch_async(dispatch_get_main_queue()) {
            view.show()
        }
    }
    
    func showErrorMessage(message:String, forPeriod:UInt64 = 2) {
        var view = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: nil)
        
        dispatch_async(dispatch_get_main_queue()) {
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(forPeriod * NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue(), {
                view.dismissWithClickedButtonIndex(-1, animated: true)
            })
            view.show()
        }
    }
    
    func showMessage(_ title:String?, message:String) {
        var view = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        
        dispatch_async(dispatch_get_main_queue()) {
            dispatch_after(2, dispatch_get_main_queue(), {
                view.dismissWithClickedButtonIndex(-1, animated: true)
            })
        }
    }
    
    class ConfirmPaymentDelegate:NSObject, UIAlertViewDelegate {
        var cloverConnector:ICloverConnector
        var req:ConfirmPaymentRequest
        var ex:BaseExecutor
        var index:Int
        
        init(cc:ICloverConnector, executor:BaseExecutor, request:ConfirmPaymentRequest, challengeIndex:Int) {
            self.cloverConnector = cc
            req = request
            index = challengeIndex
            ex = executor
            super.init()
        }
        
        func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
            switch buttonIndex {
                case 0: if index == req.challenges!.count-1 {
                    cloverConnector.acceptPayment(req.payment!)
                } else {
                    ex.promptForChallenge(req, challengeIndex: index+1)
                }
                case 1: cloverConnector.rejectPayment(req.payment!, challenge: req.challenges![index])
                default:
                    cloverConnector.acceptPayment(req.payment!)
            }
        }
    }

    class VerifySignatureDelegate:NSObject, UIAlertViewDelegate {
        var cloverConnector:ICloverConnector
        var request:VerifySignatureRequest
        
        init(cloverConnector:ICloverConnector, request:VerifySignatureRequest) {
            self.cloverConnector = cloverConnector
            self.request = request
        }
        
        func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
            switch buttonIndex {
            case 0:
                cloverConnector.acceptSignature(request)
            case 1:
                cloverConnector.rejectSignature(request)
            default:
                cloverConnector.acceptSignature(request)
            }
        }
    }
}

protocol Executor {
    func run()
}

class VaultCardExecutor:BaseExecutor, Executor {
    var after:((CLVModels.Payments.VaultedCard) -> Void)?
    
    func run() {
        guard let cloverConnector = cloverConnector else { return }
        let vcr = VaultCardRequest()
        vcr.cardEntryMethods = cloverConnector.CARD_ENTRY_METHOD_MAG_STRIPE | cloverConnector.CARD_ENTRY_METHOD_ICC_CONTACT | cloverConnector.CARD_ENTRY_METHOD_NFC_CONTACTLESS
        cloverConnector.addCloverConnectorListener(self)
        cloverConnector.vaultCard(vcr)
    }
    
    override func onVaultCardResponse(vaultCardResponse: VaultCardResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if vaultCardResponse.success {
            if let card = vaultCardResponse.card,
                let afterMethod = after {
                afterMethod(card)
            }
        } else {
            showErrorMessage("Vault Card Failed")
        }
    }
}

class PaymentExecutor:BaseExecutor, UIAlertViewDelegate, Executor {
    var view:UIAlertView?
    var transactionSettings:CLVModels.Payments.TransactionSettings?
    var cardNotPresent:Bool?
    var amount:Int?
    var tipAmount:Int?
    var vaultedCard:CLVModels.Payments.VaultedCard?
    
    deinit {
        debugPrint("deinit PaymentExecutor")
    }
    
    func run() {
        view = UIAlertView(title: "Payment", message: "What payment type?", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Sale", "Auth", "PreAuth", "Manual Refund")
        view?.alertViewStyle = UIAlertViewStyle.Default
        
        dispatch_async(dispatch_get_main_queue()) {
            self.view?.show()
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            processAsSale()
        case 1:
            processAsAuth()
        case 2:
            processAsPreAuth()
        case 3:
            processAsManualRefund()
        default: break
        }
    }

    
    override func onSaleResponse(response: SaleResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if response.success {
            let rpe = RefundPaymentExecutor(cloverConnector: cloverConnector!, payment: response.payment!)
            rpe.run()
        } else {
            showErrorMessage("Sale Failed. " + (response.reason ?? "") + ":" + (response.message ?? ""))
        }
    }
    
    override func onAuthResponse(authResponse: AuthResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if authResponse.success {
            let tae = TipAdjustExecutor(cloverConnector: cloverConnector!, payment: authResponse.payment!)
            tae.run()
        } else {
            showErrorMessage("Auth Failed. " + (authResponse.reason ?? "") + ":" + (authResponse.message ?? ""))
        }
    }
    
    override func onPreAuthResponse(preAuthResponse: PreAuthResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if preAuthResponse.success {
            let cpae = CapturePreAuthExecutor(cloverConnector: cloverConnector!, payment: preAuthResponse.payment!)
            cpae.run()
        } else {
            showErrorMessage("PreAuth Failed. " + (preAuthResponse.reason ?? "") + ":" + (preAuthResponse.message ?? ""))
        }
    }
    
    override func onManualRefundResponse(manualRefundResponse: ManualRefundResponse) {
        if manualRefundResponse.success {
            showMessage("Success", message: "Manual Refund Successful")
        } else {
            showErrorMessage("Manual Refund Failed. " + (manualRefundResponse.reason ?? "") + ":" + (manualRefundResponse.message ?? ""))
        }
    }
}

extension PaymentExecutor {
    
    private func processAsSale() {
        cloverConnector?.addCloverConnectorListener(self)
        
        let sr = SaleRequest(amount: amount ?? 2300, externalId: String(arc4random()))
        sr.allowOfflinePayment = transactionSettings?.allowOfflinePayment
        sr.approveOfflinePaymentWithoutPrompt = transactionSettings?.approveOfflinePaymentWithoutPrompt
        sr.disableCashback = transactionSettings?.disableCashBack
        if let tm = transactionSettings?.tipMode {
            switch tm {
            case .NO_TIP: sr.tipMode = .NO_TIP
            case .TIP_PROVIDED: sr.tipMode = .TIP_PROVIDED
            case .ON_SCREEN_AFTER_PAYMENT: sr.tipMode = SaleRequest.TipMode.ON_SCREEN_BEFORE_PAYMENT
            default: sr.tipMode = .NO_TIP
            }
            sr.tipMode = SaleRequest.TipMode(rawValue: tm.rawValue)
        }
        sr.disableReceiptSelection = transactionSettings?.disableReceiptSelection
        sr.disableDuplicateChecking = transactionSettings?.disableDuplicateCheck
        if let cshr = transactionSettings?.cloverShouldHandleReceipts {
            sr.disablePrinting = !cshr
        }
        sr.autoAcceptSignature = transactionSettings?.autoAcceptSignature
        sr.autoAcceptPaymentConfirmations = transactionSettings?.autoAcceptPaymentConfirmations
        sr.disableRestartTransactionOnFail = transactionSettings?.disableRestartTransactionOnFailure
        sr.signatureEntryLocation = transactionSettings?.signatureEntryLocation
        sr.cardEntryMethods = (transactionSettings?.cardEntryMethods)!
        sr.vaultedCard = self.vaultedCard
        sr.forceOfflinePayment = transactionSettings?.forceOfflinePayment
        sr.cardNotPresent = cardNotPresent
        
        if (transactionSettings?.tipMode) != nil {
            sr.disableTipOnScreen = (transactionSettings?.tipMode)!.rawValue == SaleRequest.TipMode.NO_TIP.rawValue || (transactionSettings?.tipMode)!.rawValue == SaleRequest.TipMode.TIP_PROVIDED.rawValue
        }
        sr.tipAmount = tipAmount
        cloverConnector?.sale(sr)
    }
    
    private func processAsAuth() {
        cloverConnector?.addCloverConnectorListener(self)
        
        let ar = AuthRequest(amount: amount ?? 2400, externalId: String(arc4random()))
        ar.allowOfflinePayment = transactionSettings?.allowOfflinePayment
        ar.approveOfflinePaymentWithoutPrompt = transactionSettings?.approveOfflinePaymentWithoutPrompt
        ar.disableCashback = transactionSettings?.disableCashBack
        ar.disableReceiptSelection = transactionSettings?.disableReceiptSelection
        ar.disableDuplicateChecking = transactionSettings?.disableDuplicateCheck
        if let cshr = transactionSettings?.cloverShouldHandleReceipts {
            ar.disablePrinting = !cshr
        }
        ar.autoAcceptSignature = transactionSettings?.autoAcceptSignature
        ar.autoAcceptPaymentConfirmations = transactionSettings?.autoAcceptPaymentConfirmations
        ar.disableRestartTransactionOnFail = transactionSettings?.disableRestartTransactionOnFailure
        ar.signatureEntryLocation = transactionSettings?.signatureEntryLocation
        ar.cardEntryMethods = (transactionSettings?.cardEntryMethods)!
        ar.vaultedCard = self.vaultedCard
        ar.forceOfflinePayment = transactionSettings?.forceOfflinePayment
        ar.cardNotPresent = cardNotPresent
        cloverConnector?.auth(ar)
    }
    
    private func processAsPreAuth() {
        cloverConnector?.addCloverConnectorListener(self)
        
        let par = PreAuthRequest(amount: amount ?? 2500, externalId: String(arc4random()))
        par.disableReceiptSelection = transactionSettings?.disableReceiptSelection
        par.disableDuplicateChecking = transactionSettings?.disableDuplicateCheck
        if let cshr = transactionSettings?.cloverShouldHandleReceipts {
            par.disablePrinting = !cshr
        }
        par.autoAcceptSignature = transactionSettings?.autoAcceptSignature
        par.autoAcceptPaymentConfirmations = transactionSettings?.autoAcceptPaymentConfirmations
        par.disableRestartTransactionOnFail = transactionSettings?.disableRestartTransactionOnFailure
        par.signatureEntryLocation = transactionSettings?.signatureEntryLocation
        par.cardEntryMethods = (transactionSettings?.cardEntryMethods)!
        par.cardNotPresent = cardNotPresent
        par.vaultedCard = self.vaultedCard
        
        cloverConnector?.preAuth(par)
    }
    
    private func processAsManualRefund() {
        cloverConnector?.addCloverConnectorListener(self)
        
        let mrr = ManualRefundRequest(amount: amount ?? 2200, externalId: String(arc4random()))
        mrr.disableReceiptSelection = transactionSettings?.disableReceiptSelection
        mrr.disableDuplicateChecking = transactionSettings?.disableDuplicateCheck
        if let cshr = transactionSettings?.cloverShouldHandleReceipts {
            mrr.disablePrinting = !cshr
        }
        mrr.autoAcceptSignature = transactionSettings?.autoAcceptSignature
        mrr.autoAcceptPaymentConfirmations = transactionSettings?.autoAcceptPaymentConfirmations
        mrr.disableRestartTransactionOnFail = transactionSettings?.disableRestartTransactionOnFailure
        mrr.signatureEntryLocation = transactionSettings?.signatureEntryLocation
        mrr.cardEntryMethods = (transactionSettings?.cardEntryMethods)!
        mrr.cardNotPresent = cardNotPresent
        cloverConnector?.manualRefund(mrr)
    }
}

class CapturePreAuthExecutor:BaseExecutor, UIAlertViewDelegate {
    func run() {
        self.delegate = self
        let view = UIAlertView(title: "Capture", message: "Would you like to capture the pre-Auth?", delegate: delegate, cancelButtonTitle: nil, otherButtonTitles: "Yes", "No")
        view.alertViewStyle = UIAlertViewStyle.Default
        
        dispatch_async(dispatch_get_main_queue()) {
            view.show()
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            self.cloverConnector!.addCloverConnectorListener(self)
            let cpar = CapturePreAuthRequest(amount: 4500, paymentId: self.payment!.id!)
            self.cloverConnector!.capturePreAuth(cpar)
            break
        case 1:
            let vpe = VoidPaymentExecutor(cloverConnector: cloverConnector!, payment: payment!)
            vpe.run()
            break
        default:
            break
        }
    }
    
    override func onCapturePreAuthResponse(capturePreAuthResponse: CapturePreAuthResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if capturePreAuthResponse.success {
            let tae = TipAdjustExecutor(cloverConnector: cloverConnector!, payment: payment!)
            tae.run()
        } else {
            showErrorMessage("Capture Failed. " + (capturePreAuthResponse.reason ?? "") + ":" + (capturePreAuthResponse.message ?? ""))
        }
    }
}

class TipAdjustExecutor:BaseExecutor, UIAlertViewDelegate {
    func run() {
        self.delegate = self
        let view = UIAlertView(title: "Tip", message: "Would you like to add a $200 tip?", delegate: delegate, cancelButtonTitle: nil, otherButtonTitles: "Yes", "No")
        view.alertViewStyle = UIAlertViewStyle.Default
        
        dispatch_async(dispatch_get_main_queue()) {
            view.show()
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            self.cloverConnector!.addCloverConnectorListener(self)
            let taar = TipAdjustAuthRequest(orderId: self.payment!.order!.id!, paymentId: self.payment!.id!, tipAmount: 200)
            self.cloverConnector!.tipAdjustAuth(taar)
            break
        case 1:
            let rpe = RefundPaymentExecutor(cloverConnector: cloverConnector!, payment: payment!)
            rpe.run()
            break
        default:
            break
        }
    }
    
    override func onTipAdjustAuthResponse(tipAdjustAuthResponse: TipAdjustAuthResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if tipAdjustAuthResponse.success {
            let rpe = RefundPaymentExecutor(cloverConnector: cloverConnector!, payment: payment!)
            rpe.run()
        } else {
            showErrorMessage("Tip Adjust Failed. " + (tipAdjustAuthResponse.reason ?? "") + ":" + (tipAdjustAuthResponse.message ?? ""))
        }
    }
}

class RefundPaymentExecutor:BaseExecutor, UIAlertViewDelegate  {
    
    var full:Bool = false
    
    deinit {
        debugPrint("RefundPaymentExecotur d'tor")
    }
    
    func run() {
        self.delegate = self
        let view = UIAlertView(title: "Refund", message: "Would you like to refund the payment?", delegate: delegate, cancelButtonTitle: nil, otherButtonTitles: "Full", "Partial (Sale only)", "No")
        view.alertViewStyle = UIAlertViewStyle.Default
        
        dispatch_async(dispatch_get_main_queue()) {
            view.show()
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        var rpr:RefundPaymentRequest?
        switch buttonIndex {
        case 0:
            self.cloverConnector!.addCloverConnectorListener(self)
            full = true
            rpr = RefundPaymentRequest(orderId: self.payment!.order!.id!, paymentId: self.payment!.id!, fullRefund: true)
            break
        case 1:
            self.cloverConnector!.addCloverConnectorListener(self)
            full = false
            let half = Int(payment!.amount! / 2)
            rpr = RefundPaymentRequest(orderId: self.payment!.order!.id!, paymentId: self.payment!.id!, amount: Int(half))
            break
        default:
            full = false
            let vpe = VoidPaymentExecutor(cloverConnector: cloverConnector!, payment: self.payment!)
            vpe.run()
            break
        }
        if let rpr = rpr {
            self.cloverConnector!.refundPayment(rpr)
        }
    }
    
    override func onRefundPaymentResponse(refundPaymentResponse: RefundPaymentResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if refundPaymentResponse.success {
            if !full {
                let vpe = VoidPaymentExecutor(cloverConnector: cloverConnector!, payment: self.payment!)
                vpe.run()
            } else {
                let pre = PrintReceiptExecutor(cloverConnector: cloverConnector!, payment: self.payment!)
                pre.run()
            }
        } else {
            showErrorMessage("Refund Payment Failed. " + (refundPaymentResponse.reason ?? "") + ":" + (refundPaymentResponse.message ?? ""))
        }
    }
}

class VoidPaymentExecutor:BaseExecutor, UIAlertViewDelegate {
    
    func run() {
        self.delegate = self
        let view = UIAlertView(title: "Void?", message: "Would you like to void?", delegate: delegate, cancelButtonTitle: nil, otherButtonTitles: "Yes", "No")
        view.alertViewStyle = UIAlertViewStyle.Default
        
        dispatch_async(dispatch_get_main_queue()) {
            view.show()
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        var vpr:VoidPaymentRequest?
        switch buttonIndex {
        case 0:
            cloverConnector?.addCloverConnectorListener(self)
            vpr = VoidPaymentRequest(orderId: (self.payment!.order?.id)!, paymentId: self.payment!.id!, voidReason: .USER_CANCEL)
            self.cloverConnector!.voidPayment(vpr!)
        default:
            // nothing to do, so finish and go back
            //let pre = new PrintReceiptExecutor(cloverConnector: cloverConnector, payment: payment)
            let pre = PrintReceiptExecutor(cloverConnector: cloverConnector!, payment: self.payment!)
            pre.run()
        }

    }
    
    override func onVoidPaymentResponse(voidPaymentResponse: VoidPaymentResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if voidPaymentResponse.success {
            // TODO: should we be done? what will print?
            let pre = PrintReceiptExecutor(cloverConnector: cloverConnector!, payment: self.payment!)
            pre.run()
        } else {
            debugPrint("void failed")
        }
    }
}

class PrintReceiptExecutor:BaseExecutor, UIAlertViewDelegate {

    
    func run() {
        delegate = self
        let view = UIAlertView(title: "Receipt?", message: "Would you like to display the receipt screen?", delegate: delegate, cancelButtonTitle: nil, otherButtonTitles: "Yes", "No")
        view.alertViewStyle = UIAlertViewStyle.Default
        
        dispatch_async(dispatch_get_main_queue()) {
            view.show()
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            //            cloverConnector.addCloverConnectorListener(self) // only add if remote print = true
            cloverConnector!.displayPaymentReceiptOptions((payment?.order?.id)!, paymentId: payment!.id!)
        default: break
            // do nothing...
        }
    }

}
