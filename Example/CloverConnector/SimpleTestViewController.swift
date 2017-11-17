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
    
    fileprivate var cloverConnector:ICloverConnector? {
        get {
            return (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector
        }
    }
    
    fileprivate var store:POSStore? {
        get {
            return (UIApplication.shared.delegate as? AppDelegate)?.store
        }
    }
    
    fileprivate var _id = 0
    fileprivate var id : Int {
        get {
            _id = _id+1
            return _id
        }
    }
    
    @IBAction func processTXLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let cloverConnector = cloverConnector else { return }
        
        if sender.state == .began {
            // vault the card...
            let vce = VaultCardExecutor(cloverConnector: cloverConnector, parentViewController: self, payment: nil)
            vce.after = {
                card in
                DispatchQueue.main.async {
                    self.processTx(card)
                }
            }
            vce.run()
        }
        
    }
    
    @IBAction func onTipModeChanged(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func processTxClicked(_ sender: UIButton) {
        processTx(nil)
    }
    
    func updateUIFromSettings() {
        if let tx = store?.transactionSettings,
            let cloverConnector = (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector {
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
            manualSwitch.isOn = ((tx.cardEntryMethods ?? 0) & cloverConnector.CARD_ENTRY_METHOD_MANUAL) == cloverConnector.CARD_ENTRY_METHOD_MANUAL
            swipeSwitch.isOn = ((tx.cardEntryMethods ?? 0) & cloverConnector.CARD_ENTRY_METHOD_MAG_STRIPE) == cloverConnector.CARD_ENTRY_METHOD_MAG_STRIPE
            chipSwitch.isOn = ((tx.cardEntryMethods ?? 0) & cloverConnector.CARD_ENTRY_METHOD_ICC_CONTACT) == cloverConnector.CARD_ENTRY_METHOD_ICC_CONTACT
            nfcSwitch.isOn = ((tx.cardEntryMethods ?? 0) & cloverConnector.CARD_ENTRY_METHOD_NFC_CONTACTLESS) == cloverConnector.CARD_ENTRY_METHOD_NFC_CONTACTLESS
            
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
        cem |= (swipeSwitch.isOn ? cloverConnector.CARD_ENTRY_METHOD_MAG_STRIPE : 0)
        cem |= (chipSwitch.isOn ? cloverConnector.CARD_ENTRY_METHOD_ICC_CONTACT : 0)
        cem |= (nfcSwitch.isOn ? cloverConnector.CARD_ENTRY_METHOD_NFC_CONTACTLESS : 0)
        cem |= (manualSwitch.isOn ? cloverConnector.CARD_ENTRY_METHOD_MANUAL : 0)
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

        self.currentExecutor = PaymentExecutor(cloverConnector: cloverConnector, parentViewController: self, payment: nil)
        
        if let pe = self.currentExecutor as? PaymentExecutor {
            pe.cardNotPresent = store?.cardNotPresent
        }
        
        if let amt = Int(txAmount.text ?? "2525") {
            (self.currentExecutor as? PaymentExecutor)?.amount = amt
        } else {
            (self.currentExecutor as? PaymentExecutor)?.amount = 2525
        }
        if let ta = saleTipAmount.text {
            if let tipAmount = Int(ta) {
                (self.currentExecutor as? PaymentExecutor)?.tipAmount = tipAmount
            }
        }
    }
    
    func processTx(_ card:CLVModels.Payments.VaultedCard?)
    {
        if let amt = Int(txAmount.text ?? "2525") {
            (self.currentExecutor as? PaymentExecutor)?.amount = amt
        } else {
            (self.currentExecutor as? PaymentExecutor)?.amount = 2525
        }

        (self.currentExecutor as? PaymentExecutor)?.transactionSettings = store?.transactionSettings
        (self.currentExecutor as? PaymentExecutor)?.vaultedCard = card
        currentExecutor?.run()
    }
    
    
    @IBAction func resetDevice(_ sender: UIButton) {
        cloverConnector?.resetDevice()
    }



    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let cloverConnector = cloverConnector {
            self.currentExecutor = self.currentExecutor ?? PaymentExecutor(cloverConnector: cloverConnector, parentViewController: self, payment: nil)
        }
        if let listener = (UIApplication.shared.delegate as? AppDelegate)?.cloverConnectorListener {
            cloverConnector?.removeCloverConnectorListener(listener)
        }
        if let listener = (UIApplication.shared.delegate as? AppDelegate)?.testCloverConnectorListener {
            cloverConnector?.removeCloverConnectorListener(listener)
        }
        updateUIFromSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // default back to the default controller, the other tabs can switch
        if let listener = (UIApplication.shared.delegate as? AppDelegate)?.cloverConnectorListener {
            cloverConnector?.addCloverConnectorListener(listener)
        }
    }
    
    
}



class Collector {
    //inputs
    var txSettings:CLVModels.Payments.TransactionSettings?
    var request:TransactionRequest?
}

class BaseExecutor : DefaultCloverConnectorListener {
    var payment:CLVModels.Payments.Payment?
    var parentViewController:UIViewController
    
    // run this next by default
    var executor:Executor?
    var delegate:UIAlertViewDelegate?
    
    init(cloverConnector:ICloverConnector, parentViewController:UIViewController, payment:CLVModels.Payments.Payment?, nextExecutor ex:Executor? = nil) {
        self.executor = ex
        self.payment = payment
        self.parentViewController = parentViewController
        super.init(cloverConnector: cloverConnector)
    }
    
    override func onVerifySignatureRequest(_ signatureVerifyRequest: VerifySignatureRequest) {
        let alert = UIAlertController(title: "Verify", message: "Verify Signature", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] alert in
            self?.cloverConnector?.acceptSignature(signatureVerifyRequest)
        }))
        alert.addAction(UIAlertAction(title: "Reject", style: .cancel, handler: { [weak self] alert in
            self?.cloverConnector?.rejectSignature(signatureVerifyRequest)
        }))
        
        DispatchQueue.main.async { [weak self] in
            self?.parentViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    override func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
        promptForChallenge(request, challengeIndex: 0)
    }
    
    fileprivate func promptForChallenge(_ request:ConfirmPaymentRequest, challengeIndex index:Int) {
        guard let challenges = request.challenges else { return }
        guard index < challenges.count else { return }
        guard let payment = request.payment else { return }
        
        let alert = UIAlertController(title: "Confirm", message: (challenges[index].message ?? "No Message."), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] action in
            if index == challenges.count - 1 {
                self?.cloverConnector?.acceptPayment(payment)
            } else {
                self?.promptForChallenge(request, challengeIndex: index + 1)
            }
        }))
        alert.addAction(UIAlertAction(title: "Reject", style: .cancel, handler: { [weak self] action in
            self?.cloverConnector?.rejectPayment(payment, challenge: challenges[index])
        }))
        
        DispatchQueue.main.async { [weak self] in
            self?.parentViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func showErrorMessage(_ message:String, forPeriod:UInt64 = 2) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        DispatchQueue.main.async { [weak self] in
            let time = DispatchTime.now() + Double(Int64(forPeriod * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
            self?.parentViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func showMessage(_ title:String?, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        DispatchQueue.main.async { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
            self?.parentViewController.present(alert, animated: true, completion: nil)
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
    
    override func onVaultCardResponse(_ vaultCardResponse: VaultCardResponse) {
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

class PaymentExecutor:BaseExecutor, Executor {
    var transactionSettings:CLVModels.Payments.TransactionSettings?
    var cardNotPresent:Bool?
    var amount:Int?
    var tipAmount:Int?
    var vaultedCard:CLVModels.Payments.VaultedCard?
    
    deinit {
        debugPrint("deinit PaymentExecutor")
    }
    
    func run() {
        let alert = UIAlertController(title: "Payment", message: "What payment type?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sale", style: .default, handler: { [weak self] action in
            self?.processAsSale()
        }))
        alert.addAction(UIAlertAction(title: "Auth", style: .default, handler: { [weak self] action in
            self?.processAsAuth()
        }))
        alert.addAction(UIAlertAction(title: "PreAuth", style: .default, handler: { [weak self] action in
            self?.processAsPreAuth()
        }))
        alert.addAction(UIAlertAction(title: "Manual Refund", style: .default, handler: { [weak self] action in
            self?.processAsManualRefund()
        }))

        DispatchQueue.main.async { [weak self] in
            self?.parentViewController.present(alert, animated: true, completion: nil)
        }
    }
    


    
    override func onSaleResponse(_ response: SaleResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if response.success {
            guard let cloverConnector = cloverConnector, let payment = response.payment else { return }
            RefundPaymentExecutor(cloverConnector: cloverConnector, parentViewController: parentViewController, payment: payment).run()
        } else {
            showErrorMessage("Sale Failed. " + (response.reason ?? "") + ":" + (response.message ?? ""))
        }
    }
    
    override func onAuthResponse(_ authResponse: AuthResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if authResponse.success {
            guard let cloverConnector = cloverConnector, let payment = authResponse.payment else { return }
            TipAdjustExecutor(cloverConnector: cloverConnector, parentViewController: parentViewController, payment: payment).run()
        } else {
            showErrorMessage("Auth Failed. " + (authResponse.reason ?? "") + ":" + (authResponse.message ?? ""))
        }
    }
    
    override func onPreAuthResponse(_ preAuthResponse: PreAuthResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if preAuthResponse.success {
            guard let cloverConnector = cloverConnector, let payment = preAuthResponse.payment else { return }
            CapturePreAuthExecutor(cloverConnector: cloverConnector, parentViewController: parentViewController, payment: payment).run()
        } else {
            showErrorMessage("PreAuth Failed. " + (preAuthResponse.reason ?? "") + ":" + (preAuthResponse.message ?? ""))
        }
    }
    
    override func onManualRefundResponse(_ manualRefundResponse: ManualRefundResponse) {
        if manualRefundResponse.success {
            showMessage("Success", message: "Manual Refund Successful")
        } else {
            showErrorMessage("Manual Refund Failed. " + (manualRefundResponse.reason ?? "") + ":" + (manualRefundResponse.message ?? ""))
        }
    }

}

extension PaymentExecutor {
    
    fileprivate func processAsSale() {
        cloverConnector?.addCloverConnectorListener(self)
        
        guard let transactionSettings = transactionSettings else { return }
        
        let sr = SaleRequest(amount: amount ?? 2300, externalId: String(arc4random()))
        sr.allowOfflinePayment = transactionSettings.allowOfflinePayment
        sr.approveOfflinePaymentWithoutPrompt = transactionSettings.approveOfflinePaymentWithoutPrompt
        sr.disableCashback = transactionSettings.disableCashBack
        if let tm = transactionSettings.tipMode {
            switch tm {
            case .NO_TIP: sr.tipMode = .NO_TIP
            case .TIP_PROVIDED: sr.tipMode = .TIP_PROVIDED
            case .ON_SCREEN_AFTER_PAYMENT: sr.tipMode = SaleRequest.TipMode.ON_SCREEN_BEFORE_PAYMENT
            default: sr.tipMode = .NO_TIP
            }
            sr.tipMode = SaleRequest.TipMode(rawValue: tm.rawValue)
        }
        sr.disableReceiptSelection = transactionSettings.disableReceiptSelection
        sr.disableDuplicateChecking = transactionSettings.disableDuplicateCheck
        if let cshr = transactionSettings.cloverShouldHandleReceipts {
            sr.disablePrinting = !cshr
        }
        sr.autoAcceptSignature = transactionSettings.autoAcceptSignature
        sr.autoAcceptPaymentConfirmations = transactionSettings.autoAcceptPaymentConfirmations
        sr.disableRestartTransactionOnFail = transactionSettings.disableRestartTransactionOnFailure
        sr.signatureEntryLocation = transactionSettings.signatureEntryLocation
        sr.cardEntryMethods = transactionSettings.cardEntryMethods ?? 0
        sr.vaultedCard = self.vaultedCard
        sr.forceOfflinePayment = transactionSettings.forceOfflinePayment
        sr.cardNotPresent = cardNotPresent
        
        if let tipMode = transactionSettings.tipMode {
            sr.disableTipOnScreen = tipMode.rawValue == SaleRequest.TipMode.NO_TIP.rawValue || tipMode.rawValue == SaleRequest.TipMode.TIP_PROVIDED.rawValue
        } else {
            sr.disableTipOnScreen = false
        }
        
        sr.tipAmount = tipAmount
        cloverConnector?.sale(sr)
    }
    
    fileprivate func processAsAuth() {
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
        ar.cardEntryMethods = transactionSettings?.cardEntryMethods ?? 0
        ar.vaultedCard = self.vaultedCard
        ar.forceOfflinePayment = transactionSettings?.forceOfflinePayment
        ar.cardNotPresent = cardNotPresent
        cloverConnector?.auth(ar)
    }
    
    fileprivate func processAsPreAuth() {
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
        par.cardEntryMethods = transactionSettings?.cardEntryMethods ?? 0
        par.cardNotPresent = cardNotPresent
        par.vaultedCard = self.vaultedCard
        
        cloverConnector?.preAuth(par)
    }
    
    fileprivate func processAsManualRefund() {
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
        mrr.cardEntryMethods = transactionSettings?.cardEntryMethods ?? 0
        mrr.cardNotPresent = cardNotPresent
        cloverConnector?.manualRefund(mrr)
    }
}

class CapturePreAuthExecutor:BaseExecutor {
    func run() {
        let alert = UIAlertController(title: "Capture", message: "Would you like to capture the pre-Auth?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] action in
            guard let strongSelf = self,
                let cloverConnector = strongSelf.cloverConnector,
                let id = strongSelf.payment?.id else { return }
            cloverConnector.addCloverConnectorListener(strongSelf)
            let cpar = CapturePreAuthRequest(amount: 4500, paymentId: id)
            cloverConnector.capturePreAuth(cpar)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] action in
            guard let strongSelf = self,
                let cloverConnector = strongSelf.cloverConnector,
                let payment = strongSelf.payment else { return }
            VoidPaymentExecutor(cloverConnector: cloverConnector, parentViewController: strongSelf.parentViewController, payment: payment).run()
        }))
        
        DispatchQueue.main.async { [weak self] in
            self?.parentViewController.present(alert, animated: true, completion: nil)
        }
    }

    
    override func onCapturePreAuthResponse(_ capturePreAuthResponse: CapturePreAuthResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if capturePreAuthResponse.success {
            guard let cloverConnector = self.cloverConnector, let payment = self.payment else { return }
            let tae = TipAdjustExecutor(cloverConnector: cloverConnector, parentViewController: parentViewController, payment: payment)
            tae.run()
        } else {
            showErrorMessage("Capture Failed. " + (capturePreAuthResponse.reason ?? "") + ":" + (capturePreAuthResponse.message ?? ""))
        }
    }
}

class TipAdjustExecutor:BaseExecutor {
    func run() {
        let alert = UIAlertController(title: "Tip", message: "Would you like to add a $200 tip?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] action in
            guard let strongSelf = self,
                let cloverConnector = strongSelf.cloverConnector,
                let orderId = strongSelf.payment?.order?.id,
                let id = strongSelf.payment?.id else { return }
            cloverConnector.addCloverConnectorListener(strongSelf)
            let taar = TipAdjustAuthRequest(orderId: orderId, paymentId: id, tipAmount: 200)
            cloverConnector.tipAdjustAuth(taar)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] action in
            guard let strongSelf = self,
                let cloverConnector = strongSelf.cloverConnector,
                let payment = strongSelf.payment else { return }
            RefundPaymentExecutor(cloverConnector: cloverConnector, parentViewController: strongSelf.parentViewController, payment: payment).run()
        }))
        
        DispatchQueue.main.async { [weak self] in
            self?.parentViewController.present(alert, animated: true, completion: nil)
        }
    }
    

    
    override func onTipAdjustAuthResponse(_ tipAdjustAuthResponse: TipAdjustAuthResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if tipAdjustAuthResponse.success {
            guard let cloverConnector = cloverConnector, let payment = payment else { return }
            let rpe = RefundPaymentExecutor(cloverConnector: cloverConnector, parentViewController: parentViewController, payment: payment)
            rpe.run()
        } else {
            showErrorMessage("Tip Adjust Failed. " + (tipAdjustAuthResponse.reason ?? "") + ":" + (tipAdjustAuthResponse.message ?? ""))
        }
    }
}

class RefundPaymentExecutor:BaseExecutor {
    
    var full:Bool = false
    
    deinit {
        debugPrint("RefundPaymentExecotur d'tor")
    }
    
    func run() {
        let alert = UIAlertController(title: "Refund?", message: "Would you like to refund the payment?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Full", style: .default, handler: { [weak self] action in
            guard let strongSelf = self,
                let cloverConnector = strongSelf.cloverConnector,
                let orderId = strongSelf.payment?.order?.id,
                let id = strongSelf.payment?.id else { return }
            cloverConnector.addCloverConnectorListener(strongSelf)
            strongSelf.full = true
            cloverConnector.refundPayment(RefundPaymentRequest(orderId: orderId, paymentId: id, fullRefund: true))
        }))
        alert.addAction(UIAlertAction(title: "Partial (Sale only)", style: .default, handler: { [weak self] action in
            guard let strongSelf = self,
                let cloverConnector = strongSelf.cloverConnector,
                let orderId = strongSelf.payment?.order?.id,
                let id = strongSelf.payment?.id,
                let amount = strongSelf.payment?.amount else { return }
            cloverConnector.addCloverConnectorListener(strongSelf)
            strongSelf.full = false
            cloverConnector.refundPayment(RefundPaymentRequest(orderId: orderId, paymentId: id, amount: Int(amount / 2)))
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] action in
            guard let strongSelf = self,
                let cloverConnector = strongSelf.cloverConnector,
                let payment = strongSelf.payment else { return }
            strongSelf.full = false
            VoidPaymentExecutor(cloverConnector: cloverConnector, parentViewController: strongSelf.parentViewController, payment: payment).run()
        }))
        
        DispatchQueue.main.async { [weak self] in
            self?.parentViewController.present(alert, animated: true, completion: nil)
        }
    }
    

    
    override func onRefundPaymentResponse(_ refundPaymentResponse: RefundPaymentResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if refundPaymentResponse.success {
            if !full {
                guard let cloverConnector = cloverConnector else { return }
                let vpe = VoidPaymentExecutor(cloverConnector: cloverConnector, parentViewController: parentViewController, payment: self.payment)
                vpe.run()
            } else {
                guard let cloverConnector = cloverConnector else { return }
                let pre = PrintReceiptExecutor(cloverConnector: cloverConnector, parentViewController: parentViewController, payment: self.payment)
                pre.run()
            }
        } else {
            showErrorMessage("Refund Payment Failed. " + (refundPaymentResponse.reason ?? "") + ":" + (refundPaymentResponse.message ?? ""))
        }
    }
}

class VoidPaymentExecutor:BaseExecutor, UIAlertViewDelegate {
    
    func run() {
        guard let orderId = payment?.order?.id, let id = payment?.id else { return }

        let alert = UIAlertController(title: "Void?", message: "Would you like to void?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] action in
            guard let strongSelf = self else { return }
            strongSelf.cloverConnector?.addCloverConnectorListener(strongSelf)
            strongSelf.cloverConnector?.voidPayment( VoidPaymentRequest(orderId: orderId, paymentId: id, voidReason: .USER_CANCEL))
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] action in
            guard let cloverConnector = self?.cloverConnector, let parentViewController = self?.parentViewController, let payment = self?.payment else { return }
            PrintReceiptExecutor(cloverConnector: cloverConnector, parentViewController:parentViewController, payment: payment).run()
        }))
        
        DispatchQueue.main.async { [weak self] in
            self?.parentViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    override func onVoidPaymentResponse(_ voidPaymentResponse: VoidPaymentResponse) {
        cloverConnector?.removeCloverConnectorListener(self)
        if voidPaymentResponse.success {
            // TODO: should we be done? what will print?
            guard let cloverConnector = cloverConnector else { return }
            let pre = PrintReceiptExecutor(cloverConnector: cloverConnector, parentViewController: parentViewController, payment: self.payment)
            pre.run()
        } else {
            debugPrint("void failed")
        }
    }
}

class PrintReceiptExecutor:BaseExecutor {
    func run() {
        guard let orderId = payment?.order?.id, let id = payment?.id else { return }

        let alert = UIAlertController(title: "Receipt?", message: "Would you like to display the receipt screen?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] action in
            self?.cloverConnector?.displayPaymentReceiptOptions(orderId: orderId, paymentId: id)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        DispatchQueue.main.async { [weak self] in
            self?.parentViewController.present(alert, animated: true, completion: nil)
        }
    }
}
