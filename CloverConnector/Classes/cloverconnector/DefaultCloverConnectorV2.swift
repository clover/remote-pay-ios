//
//  DefaultCloverConnectorV2.swift
//  CloverConnector
//
//  
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class DefaultCloverConnectorV2 : NSObject, ICloverConnector {
    
    fileprivate static let KIOSK_CARD_ENTRY_METHODS:Int = 1 << 15
    
    public let CARD_ENTRY_METHOD_MAG_STRIPE:Int = 0b0001 | 0b0001_00000000 | KIOSK_CARD_ENTRY_METHODS
    public let CARD_ENTRY_METHOD_ICC_CONTACT:Int = 0b0010 | 0b0010_00000000 | KIOSK_CARD_ENTRY_METHODS
    public let CARD_ENTRY_METHOD_NFC_CONTACTLESS:Int = 0b0100 | 0b0100_00000000 | KIOSK_CARD_ENTRY_METHODS
    public let CARD_ENTRY_METHOD_MANUAL:Int = 0b1000 | 0b1000_00000000 | KIOSK_CARD_ENTRY_METHODS
    
    public var CARD_ENTRY_METHODS_DEFAULT:Int {
        return CARD_ENTRY_METHOD_MAG_STRIPE | CARD_ENTRY_METHOD_ICC_CONTACT | CARD_ENTRY_METHOD_NFC_CONTACTLESS
    }
    
    public let MAX_PAYLOAD_SIZE = 10000000 // maximum size of the payload of a full message.  if the payload exceeds this, the message will not be sent.

    let broadcaster:CloverConnectorBroadcaster = CloverConnectorBroadcaster()
    var device:CloverDevice?
    
    var deviceObserver:CloverConnectorDeviceObserver?
    var config:CloverDeviceConfiguration
    
    var isReady:Bool = false
    
    var cardEntryMethods:Int {
        return CARD_ENTRY_METHOD_MAG_STRIPE | CARD_ENTRY_METHOD_ICC_CONTACT | CARD_ENTRY_METHOD_NFC_CONTACTLESS
    }
    
    var merchantInfo = MerchantInfo()

    //MARK: Cleanup
    public func dispose() {
        broadcaster.clearAll()
        device?.dispose()
        device = nil
        deviceObserver = nil
        
        isReady = false
    }
    
    deinit {
        CCLog.d("deinit CloverConnector")
    }
    
    //MARK: Setup
    public init(config: CloverDeviceConfiguration) {
        self.config = config;
        super.init()
        deviceObserver = CloverConnectorDeviceObserver(cloverConnector: self)
    }
    
    public func addCloverConnectorListener(_ listener : ICloverConnectorListener) {
        
        broadcaster.addObject(listener);
    }
    
    public func removeCloverConnectorListener(_ listener: ICloverConnectorListener) {
        broadcaster.removeObject(listener)
    }
    
    public func initializeConnection() {
        objc_sync_enter(self)
        defer {objc_sync_exit(self)}
        
        if device == nil {
            if let device = CloverDeviceFactory.get(config),
                let deviceObserver = deviceObserver {
                device.cloverConnector = self
                device.subscribe(deviceObserver)
                self.device = device
                device.initialize()
            } else {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, cause: nil, message: "initializeConnection: The Clover Device is null, maybe the configuration is invalid"));
            }
        }
    }
    
    //MARK: TransactionRequest
    public func sale(_ saleRequest: SaleRequest) {
        guard let _ = checkDevice(from: #function) else {
            deviceObserver?.onFinishCancel(false, result:ResultCode.ERROR, reason: "Device Connection Error", message: "In sale : The device is not connected.", requestInfo: TxStartRequestMessage.SALE_REQUEST)
            return
        }
        
        if let _ = saleRequest.vaultedCard, !merchantInfo.supportsVaultCards {
            deviceObserver?.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason:"Merchant Configuration Validation Error", message:"In Sale : SaleRequest - Vault Card support is not enabled for the payment gateway. ", requestInfo: TxStartRequestMessage.SALE_REQUEST)
            return
        }
        
        saleRequest.tipAmount = saleRequest.tipAmount ?? 0 // force to zero if it isn't passed in
        saleAuth(saleRequest, requestInfo: TxStartRequestMessage.SALE_REQUEST)
    }
    
    public func auth(_ authRequest: AuthRequest) {
        guard let _ = checkDevice(from: #function) else {
            deviceObserver?.onFinishCancel(false, result:ResultCode.ERROR, reason: "Device Connection Error", message: "In auth : The device is not connected.", requestInfo: TxStartRequestMessage.AUTH_REQUEST)
            return
        }
        
        if !merchantInfo.supportsAuths {
            deviceObserver?.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason: "Merchant Configuration Validation Error", message:"In Auth : AuthRequest - Auth support is not enabled for the payment gateway.", requestInfo: TxStartRequestMessage.AUTH_REQUEST)
            return
        }
        
        if let _ = authRequest.vaultedCard, !merchantInfo.supportsVaultCards {
            deviceObserver?.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason:"Merchant Configuration Validation Error", message:"In Auth : AuthRequest - Vault Card support is not enabled for the payment gateway. ", requestInfo: TxStartRequestMessage.AUTH_REQUEST)
            return
        }
        
        saleAuth(authRequest, requestInfo:TxStartRequestMessage.AUTH_REQUEST)
    }
    
    public func tipAdjustAuth(_ tipAdjustAuthRequest: TipAdjustAuthRequest) {
        guard let device = checkDevice(from: #function) else {
            deviceObserver?.onAuthTipAdjustedResponse(false, result: ResultCode.ERROR, reason: "Device Connection Error", message: "In preAuth : The device is not connected.")
            return
        }
        
        if !merchantInfo.supportsTipAdjust {
            deviceObserver?.onAuthTipAdjustedResponse(false, result: ResultCode.UNSUPPORTED, reason: "Merchant Configuration Validation Error", message:"PreAuth : PreAuthRequest - PreAuth support is not enabled for the payment gateway.")
            return
        }
        
        device.doTipAdjustAuth(tipAdjustAuthRequest.orderId, paymentId: tipAdjustAuthRequest.paymentId, amount: tipAdjustAuthRequest.tipAmount)
    }
    
    public func preAuth(_ preAuthRequest: PreAuthRequest) {
        guard let _ = checkDevice(from: #function) else {
            deviceObserver?.onFinishCancel(false, result:ResultCode.ERROR, reason: "Device Connection Error", message: "In preAuth : The device is not connected.", requestInfo: TxStartRequestMessage.PREAUTH_REQUEST)
            return
        }
        
        if !merchantInfo.supportsPreAuths {
            deviceObserver?.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason: "Merchant Configuration Validation Error", message:"PreAuth : PreAuthRequest - PreAuth support is not enabled for the payment gateway.", requestInfo: TxStartRequestMessage.PREAUTH_REQUEST)
            return
        }
        
        if let _ = preAuthRequest.vaultedCard, !merchantInfo.supportsVaultCards {
            deviceObserver?.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason:"Merchant Configuration Validation Error", message:"In PreAuth : PreAuthRequest - Vault Card support is not enabled for the payment gateway. ", requestInfo: TxStartRequestMessage.PREAUTH_REQUEST)
            return
        }

        saleAuth(preAuthRequest, requestInfo: TxStartRequestMessage.PREAUTH_REQUEST)
    }
    
    public func capturePreAuth(_ request: CapturePreAuthRequest) {
        guard let device = checkDevice(from: #function) else {
            deviceObserver?.onCapturePreAuthResponse(false, result: ResultCode.ERROR, reason: "Device Connection Error", message: "In preAuth : The device is not connected.")
            return
        }
        
        if !merchantInfo.supportsPreAuths {
            deviceObserver?.onCapturePreAuthResponse(false, result: .UNSUPPORTED, reason: "Merchant Configuration Validation Error", message:"In PreAuth : CapturePreAuthRequest - PreAuth support is not enabled for the payment gateway.")
            return
        }
        
        if request.version == 1 { // V1 message for backward compatibility testing
            device.doCaptureAuth(request.paymentId, amount: request.amount, tipAmount: request.tipAmount ?? 0)
        } else { // V2 message includes CVM support
            let builder = PayIntent.Builder(amount: request.amount, paymentId: request.paymentId)
            builder.transactionType = TransactionType.CAPTURE_PREAUTH
            builder.tipAmount = request.tipAmount
            builder.externalPaymentId = request.externalId
            
            let tx = CLVModels.Payments.TransactionSettings()
            tx.tipMode = request.tipMode
            tx.autoAcceptSignature = request.autoAcceptsSignature
            if let disablePrinting = request.disablePrinting {
                tx.cloverShouldHandleReceipts = !disablePrinting
            }
            tx.signatureEntryLocation = request.signatureEntryLocation
            tx.disableReceiptSelection = request.disableReceiptSelection
            tx.signatureThreshold = request.signatureThreshold
            tx.tippableAmount = request.tippableAmount
            builder.transactionSettings = tx
            
            device.doCaptureAuth(payIntent: builder.build(), order: nil, requestInfo: nil)
        }
    }
    
    public func incrementPreAuth(_ incrementPreAuthRequest: IncrementPreauthRequest) {
        guard let device = checkDevice(from: #function) else {
            deviceObserver?.onIncrementPreAuthResponse(.FAIL, reason: "Device Connection Error", message: "In incrementPreAuth : The device is not connected.", auth: nil)
            return
        }
        
        guard merchantInfo.supportsPreAuths else {
            deviceObserver?.onIncrementPreAuthResponse(.ERROR, reason: "Merchant Configuration Validation Error", message: "In IncrementPreAuth : PreAuth support is not enabled for the payment gateway.", auth: nil)
            return
        }
                
        device.doIncrementPreAuth(incrementPreAuthRequest.amount, paymentId: incrementPreAuthRequest.paymentId)
    }
    
    /**
     * A common PayIntent builder method for Sale and Auth
     *
     * @param request
     */
    fileprivate func saleAuth(_ request:BaseTransactionRequest, requestInfo:String?) {
        if let device = checkDevice(from: #function) {
            deviceObserver?.lastRequest = request;
            
            let builder = PayIntent.Builder(amount: request.amount, externalId: request.externalId);
            
            builder.transactionType = request.type; // difference between sale, auth and auth(preAuth)
            if let disablePrinting = request.disablePrinting {
                builder.remotePrint  = disablePrinting
            }

            builder.cardEntryMethods = request.cardEntryMethods
            
            if let cardNotPresent = request.cardNotPresent {
                builder.isCardNotPresent = cardNotPresent
            }

            builder.vaultedCard = request.vaultedCard
            builder.requiresRemoteConfirmation = true
            
            // tx settings
            let tx = CLVModels.Payments.TransactionSettings()
            builder.transactionSettings = tx
            tx.cardEntryMethods = request.cardEntryMethods
            tx.autoAcceptPaymentConfirmations = request.autoAcceptPaymentConfirmations
            tx.disableDuplicateCheck = request.disableDuplicateChecking
            tx.disableReceiptSelection = request.disableReceiptSelection
            if let disableRestartTransactionOnFail = request.disableRestartTransactionOnFail {
                tx.disableRestartTransactionOnFailure = disableRestartTransactionOnFail
            }
            
            tx.regionalExtras = request.regionalExtras
            builder.passThroughValues = request.extras
            
            if let transactionRequest = request as? TransactionRequest {
                tx.autoAcceptSignature = transactionRequest.autoAcceptSignature
                tx.signatureEntryLocation = transactionRequest.signatureEntryLocation
                tx.signatureThreshold = transactionRequest.signatureThreshold
            }
            
            if let dp = request.disablePrinting {
                tx.cloverShouldHandleReceipts = !dp
            }
            
            if let sr = request as? SaleRequest {
                builder.tipAmount = sr.tipAmount
                builder.taxAmount = sr.taxAmount
                if let ta = sr.tippableAmount {
                    tx.tippableAmount = ta
                }
                if let tipSuggestions = sr.tipSuggestions {
                    tx.tipSuggestions = tipSuggestions
                }
                
                if let disableCashback = sr.disableCashback {
                    builder.isDisableCashBack = disableCashback
                }
                if let allowOfflinePayment = sr.allowOfflinePayment {
                    builder.allowOfflinePayment = allowOfflinePayment
                }
                if let _ = sr.approveOfflinePaymentWithoutPrompt {
                    builder.approveOfflinePaymentWithoutPrompt = sr.approveOfflinePaymentWithoutPrompt
                }
            
                // Prefer the 'tipMode' setting, but fall back to the disableTipsOnScreen (legacy) setting if provided.
                // This matches Android behavior. Ref: SSDK-151
                if let tm = sr.tipMode {
                    tx.tipMode = CLVModels.Payments.TipMode(rawValue: tm.rawValue)
                }
                
                tx.disableCashBack = sr.disableCashback
                tx.forceOfflinePayment = sr.forceOfflinePayment
            } else if let ar = request as? AuthRequest {
                builder.taxAmount = ar.taxAmount
                tx.tippableAmount = ar.tippableAmount
                builder.tipAmount = nil
                if let disableCashback = ar.disableCashback {
                    builder.isDisableCashBack = disableCashback
                }
                if let allowOfflinePayment = ar.allowOfflinePayment {
                    builder.allowOfflinePayment = allowOfflinePayment
                }
                if let _ = ar.approveOfflinePaymentWithoutPrompt {
                    builder.approveOfflinePaymentWithoutPrompt = ar.approveOfflinePaymentWithoutPrompt
                }
                tx.disableCashBack = ar.disableCashback
                tx.tipMode = CLVModels.Payments.TipMode.ON_PAPER
                tx.forceOfflinePayment = ar.forceOfflinePayment
            } else if request is PreAuthRequest {
                tx.tipMode = .NO_TIP
            }
            
            device.doTxStart(builder.build(), order: nil, requestInfo:requestInfo) //
        }
    }

    public func acceptSignature(_ signatureVerifyRequest: VerifySignatureRequest) {
        if let device = checkDevice(from: #function) {
            if let payment = signatureVerifyRequest.payment {
                device.doSignatureVerified(payment, verified: true)
            } else {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, cause: nil, message: "In acceptSignature: The payment is required"));
                return
            }
        }
    }
    
    public func rejectSignature(_ signatureVerifyRequest: VerifySignatureRequest) {
        if let device = checkDevice(from: #function) {
            if let payment = signatureVerifyRequest.payment {
                device.doSignatureVerified(payment, verified: false)
            } else {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, cause: nil, message: "In rejectSignature: The payment is required"))
                return
            }
        }
    }
    
    public func refundPayment(_ refundPaymentRequest: RefundPaymentRequest) {
        guard let device = checkDevice(from: #function) else {
            let prr = RefundPaymentResponse(success:false, result:ResultCode.FAIL, reason: "Device connection error", message: "In RefundPayment : RefundPaymentRequest device is not connected.")
            deviceObserver?.lastPRR = prr;
            deviceObserver?.onFinishCancel(TxStartRequestMessage.REFUND_REQUEST)
            return
        }
        
        device.doPaymentRefund(refundPaymentRequest.orderId,
                               paymentId: refundPaymentRequest.paymentId,
                               amount: refundPaymentRequest.amount,
                               fullRefund: refundPaymentRequest.fullRefund,
                               disablePrinting: refundPaymentRequest.disablePrinting,
                               disableReceiptSelection: refundPaymentRequest.disableReceiptSelection)
    }
    
    public func voidPaymentRefund(_ request: VoidPaymentRefundRequest) {
        guard let device = checkDevice(from: #function) else {
            deviceObserver?.onPaymentRefundVoidResponse(request.refundId, status: .ERROR, reason: "Device connection error", message: "In voidPaymentRefund(): the device is not connected")
            return
        }
        
        device.doVoidPaymentRefund(request.refundId, orderId: request.orderId, disablePrinting: request.disablePrinting, disableReceiptSelection: request.disableReceiptSelection)
    }
    
    public func manualRefund(_ manualRefundRequest: ManualRefundRequest) {
        deviceObserver?.lastRequest = manualRefundRequest
        
        guard let device = checkDevice(from: #function) else {
            deviceObserver?.onFinishCancel(false, result: ResultCode.ERROR, reason: "Device Connection Error", message: "In preAuth : The device is not connected.", requestInfo: TxStartRequestMessage.CREDIT_REQUEST)
            return
        }
        
        if !merchantInfo.supportsManualRefunds {
            deviceObserver?.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason: "Invalid argument.", message: "In ManualRefund : ManualRefundRequest - Manual Refunds support is not enabled for the payment gateway. ", requestInfo: TxStartRequestMessage.CREDIT_REQUEST)
            return
        }
        
        if let _ = manualRefundRequest.vaultedCard, !merchantInfo.supportsVaultCards {
            deviceObserver?.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason: "Invalid argument.", message: "In ManualRefund : ManualRefundRequest - VaultedCard support is not enabled for the payment gateway. ", requestInfo: TxStartRequestMessage.CREDIT_REQUEST)
            return
        }
        
        let builder = PayIntent.Builder(amount:-1*Swift.abs(manualRefundRequest.amount), externalId: manualRefundRequest.externalId)
        builder.vaultedCard = manualRefundRequest.vaultedCard
        builder.cardEntryMethods = manualRefundRequest.cardEntryMethods
        builder.transactionType = TransactionType.CREDIT
        builder.requiresRemoteConfirmation = true
        let tx = CLVModels.Payments.TransactionSettings()
        builder.transactionSettings = tx
        
        tx.cardEntryMethods = CARD_ENTRY_METHOD_MAG_STRIPE | CARD_ENTRY_METHOD_ICC_CONTACT | CARD_ENTRY_METHOD_NFC_CONTACTLESS
        tx.autoAcceptPaymentConfirmations = manualRefundRequest.autoAcceptPaymentConfirmations
        tx.autoAcceptSignature = manualRefundRequest.autoAcceptSignature
        tx.disableDuplicateCheck = manualRefundRequest.disableDuplicateChecking
        tx.disableReceiptSelection = manualRefundRequest.disableReceiptSelection
        tx.signatureEntryLocation = manualRefundRequest.signatureEntryLocation
        tx.tipMode = .NO_TIP
        
        if let dp = manualRefundRequest.disablePrinting {
            tx.cloverShouldHandleReceipts = !dp
        }
        
        device.doTxStart(builder.build(), order: nil, requestInfo: TxStartRequestMessage.CREDIT_REQUEST)
    }
    
    public func voidPayment(_ request: VoidPaymentRequest) {
        if let device = checkDevice(from: #function) {
            let payment = CLVModels.Payments.Payment()
            
            payment.id = request.paymentId
            payment.order = CLVModels.Base.Reference()
            payment.order?.id = request.orderId
            payment.employee = CLVModels.Base.Reference()
            payment.employee?.id = ""
            
            device.doVoidPayment(payment, reason: request.voidReason.rawValue, disablePrinting: request.disablePrinting, disableReceiptSelection: request.disableReceiptSelection)
        } else {
            deviceObserver?.onPaymentVoided(false, result:ResultCode.ERROR, reason: "Device Connection Error", message: "In voidPayment : The device is not connected.")
        }
    }
    
    public func vaultCard(_ vaultCardRequest: VaultCardRequest) {
        if let device = checkDevice(from: #function) {
            if merchantInfo.supportsVaultCards {
                device.doVaultCard(vaultCardRequest.cardEntryMethods ?? self.cardEntryMethods)
            } else {
                deviceObserver?.onVaultCardResponse(false, result: ResultCode.ERROR, reason: "Vault Card not supported", message: "In vaultCard: VaultCard support is not enabled for the payment gateway. ")
            }
        } else {
            deviceObserver?.onVaultCardResponse(false, result:ResultCode.UNSUPPORTED, reason: "Invalid argument.", message: "In VaultCard : VaultCard - VaultedCard support is not enabled for the payment gateway. ")
        }
    }
    
    public func closeout(_ closeoutRequest: CloseoutRequest) {
        checkDevice(from: #function)?.doCloseout(closeoutRequest.allowOpenTabs, batchId: closeoutRequest.batchId)
    }
    
    @available(*, deprecated, message: "Use new 'displayReceiptOptions()` function instead")
    public func displayPaymentReceiptOptions(orderId:String, paymentId:String) {
        checkDevice(from: #function)?.doShowPaymentReceiptScreen(orderId, paymentId:paymentId)
    }
    
    public func displayReceiptOptions(_ receiptOptionsRequest: DisplayReceiptOptionsRequest) -> Void {
        checkDevice(from: #function)?.doShowReceiptScreen(orderId: receiptOptionsRequest.orderId,
                                                          paymentId: receiptOptionsRequest.paymentId,
                                                          refundId: receiptOptionsRequest.refundId,
                                                          creditId: receiptOptionsRequest.creditId,
                                                          disablePrinting: receiptOptionsRequest.disablePrinting)
    }
    
    public func showMessage(_ message: String) {
        checkDevice(from: #function)?.doTerminalMessage(message)
    }
    
    public func sendDebugLog(_ message: String) {
        checkDevice(from: #function)?.doSendDebugLog(message)
    }
    
    public func print(_ request: PrintRequest) {
        checkDevice(from: #function)?.doPrint(request)
    }
    
    public func retrievePrinters(_ request: RetrievePrintersRequest) {
        checkDevice(from: #function)?.doRetrievePrinters(request)
    }
    
    public func retrievePrintJobStatus(_ request: PrintJobStatusRequest) {
        checkDevice(from: #function)?.doRetrievePrintJobStatus(request)
    }
    
    public func openCashDrawer(_ request: OpenCashDrawerRequest) {
        checkDevice(from: #function)?.doOpenCashDrawer(request.reason, deviceId: request.deviceId)
    }
    
    public func resetDevice() {
        checkDevice(from: #function)?.doBreak()
    }
    
    public func showWelcomeScreen() {
        checkDevice(from: #function)?.doShowWelcomeScreen()
    }
    
    public func showThankYouScreen() {
        checkDevice(from: #function)?.doShowThankYouScreen()
    }
    
    public func showDisplayOrder(_ order: DisplayOrder) {
        checkDevice(from: #function)?.doOrderUpdate(order, orderOperation: nil)
    }
    
    public func removeDisplayOrder(_ order: DisplayOrder) {
        checkDevice(from: #function)?.doOrderUpdate(DisplayOrder(), orderOperation: nil)
    }
    
    public func invokeInputOption(_ inputOption:InputOption) {
        guard let kp = inputOption.keyPress else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.VALIDATION_ERROR, code: 0, cause: nil, message: "invokeInputOption: the keyPress is required"))
            return
        }
        
        checkDevice(from: #function)?.doKeyPress(kp)
    }

    public func notifyListenersDeviceError(_ configError:CloverDeviceErrorEvent) {
        broadcaster.notifyOnDeviceError(configError)
    }
    
    public func readCardData( _ request:ReadCardDataRequest ) -> Void {
        if let device = checkDevice(from: #function) {
            let builder = PayIntent.Builder(amount: 0, externalId: String(arc4random()))
            
            if let cem:Int = request.cardEntryMethods {
                builder.cardEntryMethods = cem
            }
            
            builder.isForceSwipePinEntry = request.forceSwipePinEntry
            builder.transactionType = .DATA
            builder.requiresRemoteConfirmation = true
            
            device.doReadCardData(builder.build())
        }
    }
    
    public func acceptPayment( _ payment:CLVModels.Payments.Payment ) -> Void {
        checkDevice(from: #function)?.doAcceptPayment(payment)
    }
    
    public func rejectPayment( _ payment:CLVModels.Payments.Payment, challenge:Challenge ) -> Void {
        checkDevice(from: #function)?.doRejectPayment(payment, challenge: challenge)
    }
    
    public func retrievePendingPayments() -> Void {
        checkDevice(from: #function)?.doRetrievePendingPayments()
    }
    
    public func startCustomActivity(_ request: CustomActivityRequest) {
        checkDevice(from: #function)?.doStartActivity(action: request.action, payload: request.payload, nonBlocking: request.nonBlocking ?? false)
    }
    
    public func sendMessageToActivity(_ request: MessageToActivity) {
        checkDevice(from: #function)?.doSendMessageToActivity(action: request.action, payload: request.payload)
    }
    
    public func retrievePayment(_ request: RetrievePaymentRequest) {
        checkDevice(from: #function)?.doRetrievePayment(request.externalPayentId)
    }
    
    public func retrieveDeviceStatus(_ request: RetrieveDeviceStatusRequest) {
        checkDevice(from: #function)?.doRetrieveDeviceStatus(request.sendLastMessage)
    }
    
    func registerForCustomerProvidedData(_ request: RegisterForCustomerProvidedDataRequest) {
        let configurations = request.configurations.map( {
            CLVModels.Loyalty.LoyaltyDataConfig(configuration: $0.configuration, type: $0.type)
        })
        checkDevice(from: #function)?.doRegisterForCustomerProvidedData(configurations)
    }
    
    func setCustomerInfo(_ request: SetCustomerInfoRequest?) {
        checkDevice(from: #function)?.doSetCustomerInfo(request?.customerInfo)
    }
    
    /// Helper function to check for the presence and readiness of the CloverDevice. Handles errors for a nil or not-ready device, or returns the valid, ready device.
    ///
    /// - Parameter funcName: String representation of the function name. Usually passed here using the #function macro
    /// - Returns: CloverDevice if present and ready, nil if not
    fileprivate func checkDevice(from funcName: String) -> CloverDevice? {
        guard let device = self.device else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, cause: nil, message: sanitizedFunctionName(funcName) + ": The Clover Device is null"));
            return nil
        }
        
        if isReady == false {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, cause: nil, message: sanitizedFunctionName(funcName) + ": The Clover Device is not ready"));
            return nil
        }
        
        return device //if we got here, we know that the device is both not nil and ready; return it
    }
    
    /// Takes a string representation of a function and cleans it up so it can be used later in debug printing
    ///
    /// - Parameter funcName: String representation of the function name to be sanitized
    /// - Returns: The sanitized string, if successful, or the original string if not
    func sanitizedFunctionName(_ funcName: String) -> String {
        /*
         Example: showDisplayOrder(_ order: DisplayOrder)
         
         Using expression \(([^\)]+)\) to match all function parameters and parentheses; in this case "(_ order: DisplayOrder)". This is then removed leaving only the function name to be passed back.
         The extra slashes in the actual pattern are necessary because the compiler treats the slash as an escape character... so we have to escape them.
         */
        
        if let regex = try? NSRegularExpression(pattern: "\\(([^\\)]+)\\)", options: .caseInsensitive) {
            let sanitizedFunctionName = regex.stringByReplacingMatches(in: funcName, options: .withTransparentBounds, range: NSMakeRange(0, funcName.count), withTemplate: "")
            return sanitizedFunctionName
        }
        
        return funcName
    }
    

    class CloverConnectorDeviceObserver : CloverDeviceObserver {
        let cloverConnector:DefaultCloverConnectorV2
        var lastRequest:AnyObject?
        var lastPRR:RefundPaymentResponse?
        
        public init(cloverConnector:DefaultCloverConnectorV2) {
            self.cloverConnector = cloverConnector
        }
        
        func onAuthTipAdjustedResponse(_ paymentId: String, amount: Int, success: Bool, message: String?, reason: String?) {
            onAuthTipAdjustedResponse(success, result: success ? ResultCode.SUCCESS : ResultCode.FAIL, reason: reason, message: message, paymentId: paymentId, tipAmount: amount)
        }
        func onAuthTipAdjustedResponse(_ success: Bool, result: ResultCode, reason:String?, message:String?, paymentId: String?=nil, tipAmount: Int?=nil) {
            let taar = TipAdjustAuthResponse(success: success, result: result, paymentId: paymentId, tipAmount: tipAmount)
            taar.reason = reason
            taar.message = message
            cloverConnector.broadcaster.notifyOnTipAdjustAuthResponse(taar)
        }
        
        func onCapturePreAuthResponse(_ status: ResultStatus, reason: String?, message: String?, paymentId: String?, amount: Int?, tipAmount: Int?) {
            let success = status == .SUCCESS
            onCapturePreAuthResponse(success, result: success ? ResultCode.SUCCESS : ResultCode.FAIL, reason: reason, message: message, paymentId: paymentId, amount: amount, tipAmount: tipAmount)
        }
        func onCapturePreAuthResponse(_ success:Bool, result: ResultCode, reason: String?, message: String?, paymentId: String?=nil, amount: Int?=nil, tipAmount: Int?=nil) {
            let cpar = CapturePreAuthResponse(success: success, result: result, paymentId: paymentId, amount: amount, tipAmount: tipAmount)
            cpar.reason = reason
            cpar.message = message
            cloverConnector.broadcaster.notifyOnCapturePreAuth(cpar)
        }
        
        func onIncrementPreAuthResponse(_ status: ResultStatus, reason: String?, message: String?, auth: CLVModels.Payments.Authorization?) {
            let ipar = IncrementPreauthResponse(success: status == .SUCCESS,
                                                result: (status == .SUCCESS ? ResultCode.SUCCESS : ResultCode.FAIL),
                                                authorization: auth)
            ipar.reason = reason
            ipar.message = message
            cloverConnector.broadcaster.notifyOnIncrementPreAuth(ipar)
        }
        
        func onCashbackSelectedResponse(_ cashbackAmount: Int) {
            // TODO:
        }
        
        func onDeviceConnected(_ device: CloverDevice) {
            cloverConnector.isReady = false
            cloverConnector.broadcaster.notifyOnConnect()
        }
        
        func onDeviceDisconnected(_ device: CloverDevice) {
            cloverConnector.isReady = false
            cloverConnector.broadcaster.notifyOnDisconnect()
        }
        
        func onDeviceReady(_ device: CloverDevice, discoveryResponseMessage: DiscoveryResponseMessage) {
            cloverConnector.isReady = discoveryResponseMessage.ready ?? false
            if cloverConnector.isReady {
                cloverConnector.merchantInfo = MerchantInfo(id: discoveryResponseMessage.merchantId, mid: discoveryResponseMessage.merchantMId, name: discoveryResponseMessage.merchantName, deviceName: discoveryResponseMessage.name, deviceSerialNumber: discoveryResponseMessage.serial, deviceModel: discoveryResponseMessage.model)
                if let supportsAuth = discoveryResponseMessage.supportsAuth {
                    cloverConnector.merchantInfo.supportsAuths = supportsAuth
                }
                if let supportsPreAuth = discoveryResponseMessage.supportsPreAuth {
                    cloverConnector.merchantInfo.supportsPreAuths = supportsPreAuth
                }
                if let supportsVaultCard = discoveryResponseMessage.supportsVaultCard {
                    cloverConnector.merchantInfo.supportsVaultCards = supportsVaultCard
                }
                device.supportsAcks = discoveryResponseMessage.supportsAcknowledgement
                device.supportsVoidPaymentResponse = discoveryResponseMessage.supportsVoidPaymentResponse
                self.cloverConnector.broadcaster.notifyOnReady(cloverConnector.merchantInfo)
            } else {
                self.cloverConnector.broadcaster.notifyOnConnect();
            }
        }
        
        func onDeviceError(_ errorType: CloverDeviceErrorType, int: Int?, cause:Error?, message: String) {
            let errorEvent = CloverDeviceErrorEvent(errorType: errorType, code: int, cause:cause, message: message)
            self.cloverConnector.broadcaster.notifyOnDeviceError(errorEvent)
        }
        
        func onPaymentVoided(_ success: Bool, result:ResultCode, reason:String?, message:String?, payment: CLVModels.Payments.Payment?=nil, voidReason: VoidReason?=nil) {
            cloverConnector.device?.doShowWelcomeScreen()
            let response = VoidPaymentResponse(success:success, result: result, paymentId: payment?.id, transactionNumber: payment?.cardTransaction?.transactionNo)
            response.reason = reason
            response.message = message
            response.voidReason = voidReason
            response.payment = payment
            cloverConnector.broadcaster.notifyOnVoidPaymentResponse(response);
        }
        
        func onPaymentRefundVoidResponse(_ refundId: String, status: ResultCode, reason: String?, message: String?) {
            cloverConnector.device?.doShowWelcomeScreen()
            
            let response = VoidPaymentRefundResponse(success: status == .SUCCESS, result: status, refundId: refundId, reason: reason, message: message)
            cloverConnector.broadcaster.notifyOnPaymentRefundVoidResponse(response)
        }
        
        func onPaymentVoided(_ payment: CLVModels.Payments.Payment, voidReason:VoidReason?, result:ResultStatus, reason:String?, message:String?) {
            let success = result == .SUCCESS
            onPaymentVoided(
                success,
                result: success ? .SUCCESS : .FAIL,
                reason:reason ?? result.rawValue,
                message:message ?? "No extended information provided.",
                payment:payment,
                voidReason: voidReason)
        }
        
        fileprivate func onVaultCardResponse(_ success:Bool, result:ResultCode, reason:String?, message:String?, vaultedCard:CLVModels.Payments.VaultedCard?=nil) {
            cloverConnector.device?.doShowWelcomeScreen()
            let response = VaultCardResponse(success:success, result:result)
            response.reason = reason
            response.message = message
            response.card = vaultedCard
            cloverConnector.broadcaster.notifyOnVaultCardRespose(response)
            
        }
        func onVaultCardResponse(_ vaultedCard: CLVModels.Payments.VaultedCard?, code: ResultStatus?, reason: String?) {
            onVaultCardResponse(code == .SUCCESS, result: code == .SUCCESS ? ResultCode.SUCCESS : ResultCode.FAIL, reason: reason, message: nil, vaultedCard: vaultedCard);
        }
        
        func onCloseoutResponse(_ code: ResultStatus, reason: String, batch: CLVModels.Payments.Batch?) {
            let response = CloseoutResponse(batch: batch, success: code == .SUCCESS, result: code == .SUCCESS ? ResultCode.SUCCESS : ResultCode.FAIL)
            cloverConnector.broadcaster.notifyOnCloseoutResponse(response)
        }
        
        func onPaymentRefundResponse(_ orderId: String?, paymentId: String?, refund: CLVModels.Payments.Refund?, reason:ErrorCode?, message:String?, code: TxState) {
            
            let success:Bool = code == TxState.SUCCESS
            let resultCode = success ? ResultCode.SUCCESS : ResultCode.FAIL
            lastPRR = RefundPaymentResponse(success: success, result:resultCode, orderId: orderId, paymentId: paymentId, refund: refund, reason: reason?.rawValue, message: message)
            // listener will be notified in onFinishOk
        }
        
        fileprivate func onFinishCancel(_ success: Bool, result:ResultCode, reason:String?, message:String?, requestInfo:String?) {
            if let ri = requestInfo {
                
                switch ri {
                case TxStartRequestMessage.SALE_REQUEST:
                    lastRequest = nil
                    let saleResponse = SaleResponse(success: success, result: result)
                    saleResponse.reason = "Request Canceled"
                    saleResponse.reason = reason ?? saleResponse.reason
                    saleResponse.message = "SaleRequest canceled by user"
                    saleResponse.message = message ?? saleResponse.message
                    saleResponse.payment = nil
                    cloverConnector.broadcaster.notifyOnSaleResponse(saleResponse);
                    break
                case TxStartRequestMessage.AUTH_REQUEST:
                    lastRequest = nil
                    let authResponse = AuthResponse(success: success, result: result)
                    authResponse.reason = "Request Canceled"
                    authResponse.reason = reason ?? authResponse.reason
                    authResponse.message = "AuthRequest canceled by user"
                    authResponse.message = message ?? authResponse.message
                    authResponse.payment = nil
                    cloverConnector.broadcaster.notifyOnAuthResponse(authResponse);
                    break
                case TxStartRequestMessage.PREAUTH_REQUEST:
                    lastRequest = nil
                    let preAuthResponse = PreAuthResponse(success: success, result: result)
                    preAuthResponse.reason = "Request Canceled";
                    preAuthResponse.reason = reason ?? preAuthResponse.reason
                    preAuthResponse.message = "PreAuth Request canceled by user"
                    preAuthResponse.message = message ?? preAuthResponse.message
                    preAuthResponse.payment = nil
                    cloverConnector.broadcaster.notifyOnPreAuthResponse(preAuthResponse);
                    break
                case TxStartRequestMessage.CREDIT_REQUEST:
                    lastRequest = nil
                    let refundResponse = ManualRefundResponse(success: success, result: result)
                    refundResponse.reason = "Request Canceled"
                    refundResponse.reason = reason ?? refundResponse.reason
                    refundResponse.message = "ManualRefundRequest canceled by user"
                    refundResponse.message = message ?? refundResponse.message
                    cloverConnector.broadcaster.notifyOnManualRefundResponse(refundResponse);
                    break
                default:
                    processOldFinishCancel(success, result: result, reason: reason, message: message)
                }
            } else {
                processOldFinishCancel(success, result: result, reason: reason, message: message)
            }
            

            if let device = cloverConnector.device {
                device.doShowWelcomeScreen();
            }
        }
        fileprivate func processOldFinishCancel(_ success: Bool, result:ResultCode, reason:String?, message:String?) {
            if let lastReq = lastRequest {
                lastRequest = nil
                if lastReq is PreAuthRequest {
                    let preAuthResponse = PreAuthResponse(success: success, result: result)
                    preAuthResponse.reason = "Request Canceled";
                    preAuthResponse.reason = reason ?? preAuthResponse.reason
                    preAuthResponse.message = "PreAuth Request canceled by user"
                    preAuthResponse.message = message ?? preAuthResponse.message
                    preAuthResponse.payment = nil
                    cloverConnector.broadcaster.notifyOnPreAuthResponse(preAuthResponse);
                } else if lastReq is SaleRequest {
                    let saleResponse = SaleResponse(success: success, result: result)
                    saleResponse.reason = "Request Canceled"
                    saleResponse.reason = reason ?? saleResponse.reason
                    saleResponse.message = "SaleRequest canceled by user"
                    saleResponse.message = message ?? saleResponse.message
                    saleResponse.payment = nil
                    cloverConnector.broadcaster.notifyOnSaleResponse(saleResponse);
                } else if lastReq is AuthRequest {
                    let authResponse = AuthResponse(success: success, result: result)
                    authResponse.reason = "Request Canceled"
                    authResponse.reason = reason ?? authResponse.reason
                    authResponse.message = "AuthRequest canceled by user"
                    authResponse.message = message ?? authResponse.message
                    authResponse.payment = nil
                    cloverConnector.broadcaster.notifyOnAuthResponse(authResponse);
                } else if lastReq is ManualRefundRequest {
                    let refundResponse = ManualRefundResponse(success: success, result: result)
                    refundResponse.reason = "Request Canceled"
                    refundResponse.reason = reason ?? refundResponse.reason
                    refundResponse.message = "ManualRefundRequest canceled by user"
                    refundResponse.message = message ?? refundResponse.message
                    cloverConnector.broadcaster.notifyOnManualRefundResponse(refundResponse);
                }
                
            } else if let lastPRRequest = lastPRR {
                cloverConnector.broadcaster.notifyOnPaymentRefundResponse(lastPRRequest);
                self.lastPRR = nil;
            }
        }

        func onFinishCancel(_ requestInfo:String?) {
            onFinishCancel(false, result: ResultCode.CANCEL, reason: nil, message: nil, requestInfo: requestInfo)
        }
        
        func onFinishOk(_ credit: CLVModels.Payments.Credit) {
            lastRequest = nil
            let response = ManualRefundResponse(success: true, result: .SUCCESS, credit:credit, transactionNumber: credit.cardTransaction?.transactionNo)
            cloverConnector.broadcaster.notifyOnManualRefundResponse(response)
        }
        
        func onFinishOk(_ payment: CLVModels.Payments.Payment, signature: Signature?, requestInfo: String?) {
            
            cloverConnector.device?.doShowWelcomeScreen() // doing this first allows the handlers to change the UI behavior

            if let ri = requestInfo {
                switch ri {
                case TxStartRequestMessage.SALE_REQUEST:
                    lastRequest = nil
                    let response = SaleResponse(success:true, result:.SUCCESS)
                    response.payment = payment
                    response.signature = signature
                    cloverConnector.broadcaster.notifyOnSaleResponse(response)
                    break
                case TxStartRequestMessage.AUTH_REQUEST:
                    lastRequest = nil
                    let response = AuthResponse(success:true, result:.SUCCESS)
                    response.payment = payment
                    response.signature = signature
                    cloverConnector.broadcaster.notifyOnAuthResponse(response)
                    break
                case TxStartRequestMessage.PREAUTH_REQUEST:
                    lastRequest = nil
                    let response = PreAuthResponse(success:true, result:.SUCCESS);
                    response.payment = payment
                    response.signature = signature
                    cloverConnector.broadcaster.notifyOnPreAuthResponse(response);
                    break
                default:
                    CCLog.d("finish ok with invalid requestInfo: " + ri)
                    processOldFinishOk(payment, signature: signature)
                    break
                }
            } else {
                processOldFinishOk(payment, signature: signature)
            }
        }
        fileprivate func processOldFinishOk(_ payment: CLVModels.Payments.Payment, signature: Signature?) {
            if let lr = lastRequest {
                lastRequest = nil
                if lr is PreAuthRequest {
                    let response = PreAuthResponse(success:true, result:.SUCCESS);
                    response.payment = payment
                    response.signature = signature
                    cloverConnector.broadcaster.notifyOnPreAuthResponse(response);
                } else if lr is AuthRequest {
                    let response = AuthResponse(success:true, result:.SUCCESS)
                    response.payment = payment
                    response.signature = signature
                    cloverConnector.broadcaster.notifyOnAuthResponse(response)
                } else if lr is SaleRequest {
                    let response = SaleResponse(success:true, result:.SUCCESS)
                    response.payment = payment
                    response.signature = signature
                    cloverConnector.broadcaster.notifyOnSaleResponse(response)
                } else {
                    // this could be a problem, or this is from a re-issue receipt screen
                }
            } else {
                CCLog.w("We have a finishOK without a last request")
            }
        }
        
        func onFinishOk(_ refund: CLVModels.Payments.Refund, requestInfo:String?) {
            lastRequest = nil
            cloverConnector.device?.doShowWelcomeScreen();
            // Since finishOk is the more appropriate/consistent location in the "flow" to
            // publish the RefundResponse (like SaleResponse, AuthResponse, etc., rather
            // than after the server call, which calls onPaymetRefund),
            // we will hold on to the response from
            // onRefundResponse (Which has more information than just the refund) and publish it here
            if let _lastPRR = lastPRR, _lastPRR.refund?.id == refund.id {
                self.lastPRR = nil
                cloverConnector.broadcaster.notifyOnPaymentRefundResponse(_lastPRR);
            } else {
                let rpr = RefundPaymentResponse(success:true, result: ResultCode.SUCCESS, orderId: refund.orderRef?.id ?? nil, paymentId:refund.payment?.id ?? nil, refund:refund)
                cloverConnector.broadcaster.notifyOnPaymentRefundResponse(rpr)
            }
        }
        
        func onKeyPressed(_ keyPress: KeyPress) {
            
        }
        
        func onPartialAuthResponse(_ partialAuthAmount: Int) {
            // TODO:
        }
        
        func onTipAddedResponse(_ tipAmount: Int) {
            cloverConnector.broadcaster.notifyOnTipAdded(tipAmount);
        }
        
        func onActivityResponse(_ status:ResultCode, action a:String?, payload p:String?, failReason fr: String?) {
            let success = status == .SUCCESS
            let car = CustomActivityResponse(success: success, result: status, action: a ?? "<unknown>", payload: p)
            car.reason = fr
            
            cloverConnector.broadcaster.notifyOnCustomActivityResponse(car)
        }
        
        
        func onTxStartResponse(_ result:TxStartResponseResult, externalId:String, requestInfo: String?, message: String?, reason: String?) {
//            if let result = result {
                let success:Bool = result == TxStartResponseResult.SUCCESS ? true : false;
                if success {
                    return
                }
            
                let duplicate:Bool = result == TxStartResponseResult.DUPLICATE
                
                if requestInfo == nil {
                    oldHandleDuplicateCx(result, externalId: externalId, duplicate: duplicate)
                } else {
                    self.lastRequest = nil
                    if TxStartRequestMessage.SALE_REQUEST == requestInfo {
                        let response:SaleResponse = SaleResponse(success:false, result:ResultCode.FAIL);
                        response.reason = reason
                        if duplicate {
                            response.result = .CANCEL
                            response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                        } else {
                            response.result = .FAIL
                            response.message = message
                        }
                        cloverConnector.broadcaster.notifyOnSaleResponse(response);
                    } else if TxStartRequestMessage.AUTH_REQUEST == requestInfo {
                        let response:AuthResponse = AuthResponse(success:false, result:ResultCode.FAIL)
                        response.reason = reason
                        if duplicate {
                            response.result = .CANCEL
                            response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                        } else {
                            response.result = .FAIL
                            response.message = message
                        }
                        cloverConnector.broadcaster.notifyOnAuthResponse(response);
                    } else if TxStartRequestMessage.PREAUTH_REQUEST == requestInfo {
                        let response:PreAuthResponse = PreAuthResponse(success:false, result:ResultCode.FAIL)
                        response.reason = reason
                        if duplicate {
                            response.result = .CANCEL
                            response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                        } else {
                            response.result = .FAIL
                            response.message = message
                        }
                        cloverConnector.broadcaster.notifyOnPreAuthResponse(response);
                    } else if TxStartRequestMessage.CREDIT_REQUEST == requestInfo {
                        let response:ManualRefundResponse = ManualRefundResponse(success:false, result:ResultCode.FAIL)
                        response.reason = reason
                        if duplicate {
                            response.result = .CANCEL
                            response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                        } else {
                            response.result = .FAIL
                            response.message = message
                        }
                        cloverConnector.broadcaster.notifyOnManualRefundResponse(response);
                    }
                }

//            } else {
//                self.lastRequest = nil
//                return;
//            }

        }
        
        fileprivate func oldHandleDuplicateCx(_ result:TxStartResponseResult?, externalId:String, duplicate:Bool) {
            let reasonString = result?.rawValue ?? ""
            
            
            if (self.lastRequest as? PreAuthRequest) != nil {
                self.lastRequest = nil
                let response:PreAuthResponse = PreAuthResponse(success:false, result:ResultCode.FAIL)
                if duplicate {
                    response.result = .CANCEL
                    response.reason = reasonString
                    response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                } else {
                    response.result = .FAIL
                    response.reason = reasonString
                }
                cloverConnector.broadcaster.notifyOnPreAuthResponse(response);
            }
            else if (self.lastRequest as? AuthRequest) != nil {
                self.lastRequest = nil
                let response:AuthResponse = AuthResponse(success:false, result:ResultCode.FAIL)
                if duplicate {
                    response.result = .CANCEL
                    response.reason = reasonString
                    response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                } else {
                    response.result = .FAIL
                    response.reason = reasonString
                }
                cloverConnector.broadcaster.notifyOnAuthResponse(response);
            }
            else if (self.lastRequest as? SaleRequest) != nil {
                self.lastRequest = nil
                let response:SaleResponse = SaleResponse(success:false, result:ResultCode.FAIL);
                if duplicate {
                    response.result = .CANCEL
                    response.reason = reasonString
                    response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                } else {
                    response.result = .FAIL
                    response.reason = reasonString
                }
                cloverConnector.broadcaster.notifyOnSaleResponse(response);
            }
            else if (self.lastRequest as? ManualRefundRequest) != nil
            {
                self.lastRequest = nil
                let response:ManualRefundResponse = ManualRefundResponse(success:false, result:ResultCode.FAIL)
                if duplicate {
                    response.result = .CANCEL
                    response.reason = reasonString
                    response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                } else {
                    response.result = .FAIL
                    response.reason = reasonString
                }
                cloverConnector.broadcaster.notifyOnManualRefundResponse(response);
            }

        }
    
        func onUiState(_ uiState: UiState, uiText: String, uiDirection: UiState.UiDirection, inputOptions: [InputOption]?) {
            guard let eventState = CloverDeviceEvent.DeviceEventState(rawValue:uiState.rawValue) else {
                CCLog.d("Unsupported UI event type: \(uiState)")
                return
            }
            if uiDirection == UiState.UiDirection.ENTER {
                cloverConnector.broadcaster.notifyOnDeviceActivityStart(CloverDeviceEvent(eventState: eventState, message: uiText, inputOptions: inputOptions))
            } else if uiDirection == UiState.UiDirection.EXIT {
                cloverConnector.broadcaster.notifyOnDeviceActivityEnd(CloverDeviceEvent(eventState: eventState, message: uiText))
            }
        }
        
        func onVerifySignature(_ payment: CLVModels.Payments.Payment, signature: Signature?) {
            let svr:VerifySignatureRequest = VerifySignatureRequest()
            svr.payment = payment
            svr.signature = signature
            
            cloverConnector.broadcaster.notifyOnVerifySignatureRequest(svr)
        }
        
        func onConfirmPayment(_ payment: CLVModels.Payments.Payment?, challenges: [Challenge]?) {
            let cpr = ConfirmPaymentRequest()
            cpr.payment = payment
            cpr.challenges = challenges
            cloverConnector.broadcaster.notifyOnConfirmPayment(cpr)
        }
 
        // TODO:
        func onMessageAck(_ sourceMessageId: String) {
            
        }
        
        func onPendingPaymentsResponse(_ success: Bool, payments: [PendingPaymentEntry]?) {
            let ppr = RetrievePendingPaymentsResponse(code: success ? ResultCode.SUCCESS : ResultCode.FAIL, message:"", payments:payments)

            cloverConnector.broadcaster.notifyOnPendingPaymentsResponse(ppr);
        }
        
        func onPrintCredit(_ credit: CLVModels.Payments.Credit) {
            let printCreditResponse = PrintManualRefundReceiptMessage(credit: credit)
            printCreditResponse.credit = credit
            cloverConnector.broadcaster.notifyPrintCredit(printCreditResponse)
        }
        
        func onPrintCreditDecline(_ reason: String, credit: CLVModels.Payments.Credit?) {
            let printCreditDecline = PrintManualRefundDeclineReceiptMessage(credit: credit, reason: reason)
            
            cloverConnector.broadcaster.notifyPrintCreditDecline(printCreditDecline)
        }
        
        func onPrintMerchantReceipt(_ payment: CLVModels.Payments.Payment) {
            let printMerchant = PrintPaymentMerchantCopyReceiptMessage(payment: payment)
            cloverConnector.broadcaster.notifyOnPrintMerchantReceipt(printMerchant)
        }
        
        func onPrintPayment(_ order: CLVModels.Order.Order, payment: CLVModels.Payments.Payment) {
            let printPayment = PrintPaymentReceiptMessage(payment: payment, order: order)
            cloverConnector.broadcaster.notifyOnPrintPaymentReceipt(printPayment)
        }
        
        func onPrintPaymentDecline(_ reason: String, payment: CLVModels.Payments.Payment) {
            let printDecline = PrintPaymentDeclineReceiptMessage(payment: payment, reason: reason)
            cloverConnector.broadcaster.notifyOnPrintPaymentDeclineReceipt(printDecline)
        }
        
        func onPrintRefundPayment(_ refund: CLVModels.Payments.Refund, payment: CLVModels.Payments.Payment, order: CLVModels.Order.Order) {
            let printRefundPayment = PrintRefundPaymentReceiptMessage(payment: payment, order: order, refund: refund)
            cloverConnector.broadcaster.notifyOnPrintPaymentRefund(printRefundPayment)
        }
        
        func onReadCardResponse(_ status: ResultStatus, reason: String, cardData: CardData?) {
            let rcdr = ReadCardDataResponse(success: status == .SUCCESS, result: status == .SUCCESS ? ResultCode.SUCCESS : ResultCode.CANCEL)
            rcdr.cardData = cardData
            rcdr.reason = reason
            
            cloverConnector.broadcaster.notifyOnReadCardResponse(rcdr);
        }
        
        func onMessageFromActivity(_ action:String, payload p:String?) {
            let messageFromActivity = MessageFromActivity(action:action, payload:p)
            cloverConnector.broadcaster.notifyOnMessageFromActivity(messageFromActivity)
        }
        
        func onRetrievePaymentResponse(_ result: ResultStatus, reason: String?, queryStatus qs: QueryStatus, payment: CLVModels.Payments.Payment?, externalPaymentId epi:String?) {
            let success = result == .SUCCESS
            let retrievePaymentResponse = RetrievePaymentResponse(success: success, result: success ? ResultCode.SUCCESS : ResultCode.FAIL, queryStatus: qs, payment: payment, externalPaymentId: epi)
            retrievePaymentResponse.reason = reason
            cloverConnector.broadcaster.notifyOnRetrievePayment(retrievePaymentResponse)
        }
        
        func onRetrievePrintJobStatus(_ printRequestId:String?, status:String?) {
            let printStatusResponse = PrintJobStatusResponse(printRequestId, status: status)
            cloverConnector.broadcaster.notifyOnPrintJobStatusResponse(printStatusResponse)
        }
        
        func onRetrievePrintersResponse(_ printers:[CLVModels.Printer.Printer]?) {
            let response = RetrievePrintersResponse(printers)
            cloverConnector.broadcaster.notifyOnRetrievePrintersResponse(response)
        }
        
        func onDisplayReceiptOptionsResponse(_ result: ResultStatus, reason: String?) {
            let response = DisplayReceiptOptionsResponse(result, reason: reason)
            response.result = (result == ResultStatus.SUCCESS ? ResultCode.SUCCESS : ResultCode.FAIL)
            response.success = response.result == ResultCode.SUCCESS
            cloverConnector.broadcaster.notifyOnDisplayReceiptOptionsResponse(response)
        }
        
        func onDeviceStatusResponse(_ result: ResultStatus, reason: String?, state: ExternalDeviceState, subState: ExternalDeviceSubState?, data: ExternalDeviceStateData?) {
            let success = result == .SUCCESS
            let result = success ? ResultCode.SUCCESS : ResultCode.CANCEL
            let response = RetrieveDeviceStatusResponse(success: success, result: result, state: state, data: data)
            //response.subState = subState // this is for internal use only right now, and not exposed in the api
            cloverConnector.broadcaster.notifyOnDeviceStatusResponse(response)
        }
        
        func onInvalidStateTransitionResponse(_ result: ResultStatus?, reason: String?, requestedTransition: String?, state: ExternalDeviceState?, data: ExternalDeviceStateData?) {
            let istr = InvalidStateTransitionResponse(success: result == .SUCCESS,
                                                      result: (result == .SUCCESS ? ResultCode.SUCCESS : ResultCode.FAIL),
                                                      reason: reason,
                                                      requestedTransition: requestedTransition,
                                                      state: state,
                                                      data: data)
            
            cloverConnector.broadcaster.notifyOnInvalidStateTransitionResponse(istr)
        }
        
        func onResetDeviceResponse(_ result: ResultStatus, reason: String?, state: ExternalDeviceState) {
            let result = result == .SUCCESS ? ResultCode.SUCCESS : ResultCode.CANCEL
            let response = ResetDeviceResponse(result: result, state: state)
            response.reason = reason
            cloverConnector.broadcaster.notifyOnResetDeviceResponse(response)
        }
        
        func onCustomerProvidedDataMessage(_ result: ResultStatus, eventId: String?, config: CLVModels.Loyalty.LoyaltyDataConfig?, data: String?) {
            let event = CustomerProvidedDataEvent(
                success: result == .SUCCESS ? true : false,
                result: result == .SUCCESS ? ResultCode.SUCCESS : ResultCode.CANCEL,
                eventId: eventId,
                config: DataProviderConfig(type: config?.type, configuration: config?.configuration),
                data: data)
            cloverConnector.broadcaster.notifyOnCustomerProvidedDataEvent(event)
        }
        
        func onTxStartResponse(_ result: TxStartResponseResult, externalId: String) {
            let success = result == TxStartResponseResult.SUCCESS ? true : false
            if success {
                return
            }
            let duplicate = result == TxStartResponseResult.DUPLICATE
            
            if let _ = lastRequest as? PreAuthRequest
            {
                let response:PreAuthResponse = PreAuthResponse(success: false,result: ResultCode.FAIL);
                if duplicate {
                    response.result = ResultCode.CANCEL
                    response.reason = result.rawValue
                    response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                } else {
                    response.result = ResultCode.FAIL
                    response.reason = result.rawValue
                }
                cloverConnector.broadcaster.notifyOnPreAuthResponse(response);
            }
            else if let _ = lastRequest as? AuthRequest
            {
                let response = AuthResponse(success: false, result: ResultCode.FAIL);
                if duplicate {
                    response.result = ResultCode.CANCEL
                    response.reason = result.rawValue
                    response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                } else {
                    response.result = ResultCode.FAIL
                    response.reason = result.rawValue
                }
                cloverConnector.broadcaster.notifyOnAuthResponse(response);
            }
            else if let _ = lastRequest as? SaleRequest
            {
                let response = SaleResponse(success: false, result: ResultCode.FAIL);
                if duplicate {
                    response.result = ResultCode.CANCEL
                    response.reason  = result.rawValue
                    response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                } else {
                    response.result = ResultCode.FAIL
                    response.reason = result.rawValue
                }
                cloverConnector.broadcaster.notifyOnSaleResponse(response);
            }
            else if let _ = lastRequest as? ManualRefundRequest
            {
                let response = ManualRefundResponse(success: false, result: ResultCode.FAIL);
                if duplicate {
                    response.result = ResultCode.CANCEL
                    response.reason = result.rawValue
                    response.message = "The provided transaction id of " + externalId + " has already been processed and cannot be resubmitted."
                } else {
                    response.result = ResultCode.FAIL
                    response.reason = result.rawValue
                }
                cloverConnector.broadcaster.notifyOnManualRefundResponse(response);
            }
        }
    }
}
