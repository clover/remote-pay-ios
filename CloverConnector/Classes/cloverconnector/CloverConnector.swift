//
//  CloverConnector.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

@objc
public class CloverConnector : NSObject, ICloverConnector {
    
    private static let KIOSK_CARD_ENTRY_METHODS:Int = 1 << 15;
    public static let CARD_ENTRY_METHOD_MAG_STRIPE:Int = 0b0001 | 0b0001_00000000 | KIOSK_CARD_ENTRY_METHODS;
    public static let CARD_ENTRY_METHOD_ICC_CONTACT:Int = 0b0010 | 0b0010_00000000 | KIOSK_CARD_ENTRY_METHODS;
    public static let CARD_ENTRY_METHOD_NFC_CONTACTLESS:Int = 0b0100 | 0b0100_00000000 | KIOSK_CARD_ENTRY_METHODS;
    public static let CARD_ENTRY_METHOD_MANUAL:Int = 0b1000 | 0b1000_00000000 | KIOSK_CARD_ENTRY_METHODS;
    
    let broadcaster:CloverConnectorBroadcaster = CloverConnectorBroadcaster()
    var device:CloverDevice?
    
    var deviceObserver:CloverConnectorDeviceObserver?
    var config:CloverDeviceConfiguration
    
    var isReady:Bool = false
    
    let cardEntryMethods = CARD_ENTRY_METHOD_MAG_STRIPE | CARD_ENTRY_METHOD_ICC_CONTACT | CARD_ENTRY_METHOD_NFC_CONTACTLESS
    
    var merchantInfo = MerchantInfo()

    public func dispose() {
        device?.dispose()
    }
    
    @objc
    public init(config: CloverDeviceConfiguration) {
        self.config = config;
        super.init()
        deviceObserver = CloverConnectorDeviceObserver(cloverConnector: self)
    }
    
    @objc
    public func addCloverConnectorListener(_ listener : ICloverConnectorListener) {
        
        broadcaster.addObject(listener);
    }
    
    @objc
    public func removeCloverConnectorListener(_ listener: ICloverConnectorListener) {
        broadcaster.removeObject(listener)
    }
    
    @objc
    public func initializeConnection() {
        
        class ConnectionListener:DefaultCloverConnectorListener {
            private var resetAlready:Bool = false
            override func onDeviceReady(_ merchantInfo: MerchantInfo) {
                if(!resetAlready) {
                    self.cloverConnector?.resetDevice()
                }
                resetAlready = true
                self.cloverConnector?.removeCloverConnectorListener(self);
            }
        }
        
        addCloverConnectorListener(ConnectionListener(cloverConnector: self)) // the first connection, reset the device
        if let device = CloverDeviceFactory.get(config) {
            device.subscribe(deviceObserver!)
            self.device = device
            
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "initializeConnection: The Clover Device is null, maybe the configuration is invalid"));
        }
    }
    
    public func sale(_ saleRequest: SaleRequest) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "sale: The Clover Device is not ready"));
                return;
            } else if(deviceObserver?.lastRequest != nil) {
                // not using FinishCancel because that will clear the last request
                var response = SaleResponse(success: true, result: .CANCEL)
                response.reason = "Device busy"
                response.message = "The Mini appears to be busy. If not, call resetDevice()"
                broadcaster.notifyOnSaleResponse(response)
                return
            } else if(saleRequest.amount <= 0) {
                deviceObserver!.onFinishCancel(false, result:ResultCode.FAIL, reason: "Request validation error", message: "In Sale : SaleRequest - the request amount cannot be zero. ");
                return;
            } else if (saleRequest.externalId.characters.count == 0 || saleRequest.externalId.characters.count > 32){
                deviceObserver!.onFinishCancel(false, result:ResultCode.FAIL, reason: "Invalid argument.", message: "In Sale : SaleRequest - The externalId is invalid. The min length is 1 and the max length is 32. ");
                return;
            } else {
                if let card = saleRequest.vaultedCard {
                    if(!merchantInfo.supportsVaultCards) {
                        deviceObserver!.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason:"Merchant Configuration Validation Error", message:"In Sale : SaleRequest - Vault Card support is not enabled for the payment gateway. ");
                        return;
                    }
                }
            }

            let tos = saleRequest.disableTipOnScreen ?? false
            saleRequest.tipAmount = saleRequest.tipAmount ?? 0 // force to zero if it isn't passed in
            saleAuth(saleRequest, suppressTipScreen: tos)
        } else {
            deviceObserver!.onFinishCancel(false, result:ResultCode.ERROR, reason: "Device Connection Error", message: "In sale : The device is not connected.");
            //notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "initializeConnection: The Clover Device is null"));
        }
    }
    
    public func auth(_ authRequest: AuthRequest) {
        if let device = device {
            
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "auth: The Clover Device is not ready"));
                return;
            } else if(deviceObserver?.lastRequest != nil) {
                // not using FinishCancel because that will clear the last request
                var response = AuthResponse(success: true, result: .CANCEL)
                response.reason = "Device busy"
                response.message = "The Mini appears to be busy. If not, resetDevice() must be called"
                broadcaster.notifyOnAuthResponse(response)
            } else if(authRequest.amount <= 0) {
                deviceObserver!.onFinishCancel(false, result:ResultCode.FAIL, reason: "Request validation error", message: "In Auth : AuthRequest - the request amount cannot be zero. ");
                return;
            } else if (authRequest.externalId.characters.count == 0 || authRequest.externalId.characters.count > 32){
                deviceObserver!.onFinishCancel(false, result:ResultCode.FAIL, reason: "Invalid argument.", message: "In Auth : AuthRequest - The externalId is invalid. The min length is 1 and the max length is 32. ");
                return;
            } else {
                if let card = authRequest.vaultedCard {
                    if(!merchantInfo.supportsVaultCards) {
                        deviceObserver!.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason:"Merchant Configuration Validation Error", message:"In Auth : AuthRequest - Vault Card support is not enabled for the payment gateway. ");
                        return;
                    }
                }
                
                if (!merchantInfo.supportsAuths) {
                    deviceObserver!.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason: "Merchant Configuration Validation Error", message:"In Auth : AuthRequest - Auth support is not enabled for the payment gateway.")
                    return;
                }
            }
            
            saleAuth(authRequest, suppressTipScreen: true)
        } else {
            deviceObserver!.onFinishCancel(false, result:ResultCode.ERROR, reason: "Device Connection Error", message: "In auth : The device is not connected.");
            //notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "initializeConnection: The Clover Device is null"));
        }
    }
    
    public func tipAdjustAuth(_ tipAdjustAuthRequest: TipAdjustAuthRequest) {
        if let device = device {
            
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "tipAdjustAuth: The Clover Device is not ready"));
                return;
            } else if(tipAdjustAuthRequest.tipAmount <= 0) {
                deviceObserver!.onAuthTipAdjustedResponse(false, result: ResultCode.FAIL, reason: "Request validation error", message: "In PreAuth : PreAuthRequest - the request tipAmount cannot be zero. ");
                return;
            } else if !merchantInfo.supportsTipAdjust {
                deviceObserver!.onAuthTipAdjustedResponse(false, result: ResultCode.UNSUPPORTED, reason: "Merchant Configuration Validation Error", message:"PreAuth : PreAuthRequest - PreAuth support is not enabled for the payment gateway.")
                    return;
            }
            
            device.doTipAdjustAuth(tipAdjustAuthRequest.orderId, paymentId: tipAdjustAuthRequest.paymentId, amount: tipAdjustAuthRequest.tipAmount)
            
        } else {
            deviceObserver!.onAuthTipAdjustedResponse(false, result: ResultCode.ERROR, reason: "Device Connection Error", message: "In preAuth : The device is not connected.");
            //notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "initializeConnection: The Clover Device is null"));
        }
        
    }
    
    public func preAuth(_ preAuthRequest: PreAuthRequest) {
        if let device = device {
            
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "preAuth: The Clover Device is not ready"));
                return;
            } else if(preAuthRequest.amount <= 0) {
                deviceObserver!.onFinishCancel(false, result:ResultCode.FAIL, reason: "Request validation error", message: "In PreAuth : PreAuthRequest - the request amount cannot be zero. ");
                return;
            } else if (preAuthRequest.externalId.characters.count == 0 || preAuthRequest.externalId.characters.count > 32){
                deviceObserver!.onFinishCancel(false, result:ResultCode.FAIL, reason: "Invalid argument.", message: "In PreAuth : PreAuthRequest - The externalId is invalid. The min length is 1 and the max length is 32. ");
                return;
            } else {
                if let card = preAuthRequest.vaultedCard {
                    if(!merchantInfo.supportsVaultCards) {
                        deviceObserver!.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason:"Merchant Configuration Validation Error", message:"In PreAuth : PreAuthRequest - Vault Card support is not enabled for the payment gateway. ");
                        return;
                    }
                }
                
                if (!merchantInfo.supportsPreAuths) {
                    deviceObserver!.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason: "Merchant Configuration Validation Error", message:"PreAuth : PreAuthRequest - PreAuth support is not enabled for the payment gateway.")
                    return;
                }
            }
            
            saleAuth(preAuthRequest, suppressTipScreen: true)
        } else {
            deviceObserver!.onFinishCancel(false, result:ResultCode.ERROR, reason: "Device Connection Error", message: "In preAuth : The device is not connected.");
            //notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "initializeConnection: The Clover Device is null"));
        }
        
    }
    
    public func capturePreAuth(_ capturePreAuthRequest: CapturePreAuthRequest) {

        if let device = self.device {
            let tipAmount = capturePreAuthRequest.tipAmount ?? 0
            
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "capturePreAuth: The Clover Device is not ready"));
                return;
            } else if (capturePreAuthRequest.amount < 0) {
                deviceObserver!.onCapturePreAuthResponse(false, result:ResultCode.FAIL, reason: "Request validation error", message: "In capturePreAuth : The amount must be greater than 0")
            } else if tipAmount < 0 {
                deviceObserver!.onCapturePreAuthResponse(false, result:ResultCode.FAIL, reason: "Request validation error", message: "In capturePreAuth : The tipAmount must be greater than 0")
            } else if !merchantInfo.supportsPreAuths {
                deviceObserver!.onCapturePreAuthResponse(false, result:ResultCode.UNSUPPORTED, reason: "Merchant Configuration Validation Error", message: "In capturePreAuth : CapturePreAuth support is not enabled for the payment gateway")
            }
            
            
            device.doCaptureAuth(capturePreAuthRequest.paymentId, amount: capturePreAuthRequest.amount, tipAmount: tipAmount)
        } else {
            deviceObserver!.onCapturePreAuthResponse(false, result: ResultCode.ERROR, reason: "Device Connection Error", message: "In preAuth : The device is not connected.")
            //notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "initializeConnection: The Clover Device is null"));
        }
    }
    
    /**
     * A common PayIntent builder method for Sale and Auth
     *
     * @param request
     */
    private func saleAuth(_ request:TransactionRequest, suppressTipScreen:Bool) {
        if let device = self.device {
            var tos = suppressTipScreen

            deviceObserver!.lastRequest = request;
            
            let builder = PayIntent.Builder(amount: request.amount, externalId: request.externalId);
            
            builder.transactionType = request.type; // difference between sale, auth and auth(preAuth)
            if let disablePrinting = request.disablePrinting {
                builder.remotePrint  = disablePrinting
            }

            builder.cardEntryMethods = request.cardEntryMethods ?? self.cardEntryMethods
            
            if let cardNotPresent = request.cardNotPresent {
                builder.isCardNotPresent = cardNotPresent
            }
            if let disableRestartTransactionOnFail = request.disableRestartTransactionOnFail {
                builder.disableRestartTransactionOnFail = disableRestartTransactionOnFail
            }
            builder.vaultedCard = request.vaultedCard
            builder.requiresRemoteConfirmation = true
            
            // tx settings
            let tx = CLVModels.Payments.TransactionSettings()
            builder.transactionSettings = tx
            
            tx.cardEntryMethods = request.cardEntryMethods
            tx.autoAcceptPaymentConfirmations = request.autoAcceptPaymentConfirmations
            tx.autoAcceptSignature = request.autoAcceptSignature
            tx.disableDuplicateCheck = request.disableDuplicateChecking
            tx.disableReceiptSelection = request.disableReceiptSelection
            tx.signatureEntryLocation = request.signatureEntryLocation
            if let dp = request.disablePrinting {
                tx.cloverShouldHandleReceipts = !dp
            }
            
            if let sr = request as? SaleRequest {
                builder.tipAmount = sr.tipAmount
                builder.taxAmount = sr.taxAmount
                builder.tippableAmount = sr.tippableAmount
                if let disableCashback = sr.disableCashback {
                    builder.isDisableCashBack = disableCashback
                }
                if let allowOfflinePayment = sr.allowOfflinePayment {
                    builder.allowOfflinePayment = allowOfflinePayment
                }
                if let approveOfflinePaymentWithoutPrompt = sr.approveOfflinePaymentWithoutPrompt {
                    builder.approveOfflinePaymentWithoutPrompt = sr.approveOfflinePaymentWithoutPrompt
                }
                if let disableTipOnScreen = sr.disableTipOnScreen {
                    tos = disableTipOnScreen
                }
            
                if let tm = sr.tipMode {
                    tx.tipMode = CLVModels.Payments.TipMode(rawValue: tm.rawValue)
                }
                tx.disableCashBack = sr.disableCashback
            } else if let ar = request as? AuthRequest {
                builder.taxAmount = ar.taxAmount
                builder.tippableAmount = ar.tippableAmount
                if let disableCashback = ar.disableCashback {
                    builder.isDisableCashBack = disableCashback
                }
                if let allowOfflinePayment = ar.allowOfflinePayment {
                    builder.allowOfflinePayment = allowOfflinePayment
                }
                if let approveOfflinePaymentWithoutPrompt = ar.approveOfflinePaymentWithoutPrompt {
                    builder.approveOfflinePaymentWithoutPrompt = ar.approveOfflinePaymentWithoutPrompt
                }
                tx.disableCashBack = ar.disableCashback
            } else if let par = request as? PreAuthRequest {
                // do nothing extra for now...
            }
            
            if let payIntent:PayIntent = builder.build() {
                device.doTxStart(payIntent, order: nil, suppressTipScreen: tos); //
            }
            
            
        } else {
            // no device, but shouldn't get here, as the callers should have made this check
            broadcaster.notifyOnDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "Device is not connected."));
        }
    }

    public func acceptSignature(_ signatureVerifyRequest: VerifySignatureRequest) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "acceptSignature: The Clover Device is not ready"));
                return;
            } else if let payment = signatureVerifyRequest.payment {
                device.doSignatureVerified(payment, verified: true)
            } else {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "In acceptSignature: The payment is required"));
                return
            }
            
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "In acceptSignautre: The Clover Device is null"));
        }
        
    }
    
    public func rejectSignature(_ signatureVerifyRequest: VerifySignatureRequest) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "rejectSignature: The Clover Device is not ready"));
                return;
            } else if let payment = signatureVerifyRequest.payment {
                device.doSignatureVerified(payment, verified: false)
            } else {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "In rejectSignature: The payment is required"));
                return
            }
            
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "In rejectSignature: The Clover Device is not connected"));
        }
    }
    
    public func refundPayment(_ refundPaymentRequest: RefundPaymentRequest) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "refundPayment: The Clover Device is not ready"));
                return;
            } else if(!refundPaymentRequest.fullRefund && refundPaymentRequest.amount ?? 0 <= 0) {
                let prr = RefundPaymentResponse(success:false, result:ResultCode.FAIL)
                prr.refund = nil
                prr.reason = "Request Validation Error"
                prr.message = "In RefundPayment : RefundPaymentRequest Amount must be greater than zero when FullRefund is set to false. "
                deviceObserver!.lastPRR = prr;
                deviceObserver!.onFinishCancel();
                return;
            } else {
                //TODO: check for null orderId, paymentId, (amount or fullRefund)
                device.doPaymentRefund(refundPaymentRequest.orderId, paymentId: refundPaymentRequest.paymentId, amount: refundPaymentRequest.amount ?? 0, fullRefund: refundPaymentRequest.fullRefund)
            }
            
        } else {
            let prr = RefundPaymentResponse(success:false, result:ResultCode.FAIL)
            prr.refund = nil
            prr.reason = "Device connection error"
            prr.message = "In RefundPayment : RefundPaymentRequest device is not connected."
            deviceObserver!.lastPRR = prr;
            deviceObserver!.onFinishCancel();
            return;
        }

        
    }
    
    public func manualRefund(_ manualRefundRequest: ManualRefundRequest) {
        deviceObserver!.lastRequest = manualRefundRequest
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "manualRefund: The Clover Device is not ready"));
                return;
            } else if manualRefundRequest.amount <= 0 {
                deviceObserver!.onFinishCancel(false, result: ResultCode.FAIL, reason: "Invalid argument", message: "The amount must be greater than 0")
                return;
            } else if (manualRefundRequest.externalId.characters.count == 0 || manualRefundRequest.externalId.characters.count > 32){
                deviceObserver!.onFinishCancel(false, result:ResultCode.FAIL, reason: "Invalid argument.", message: "In PreAuth : ManualRefundRequest - The externalId is invalid. The min length is 1 and the max length is 32. ");
                return;
            }
            if !merchantInfo.supportsManualRefunds {
                deviceObserver!.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason: "Invalid argument.", message: "In ManualRefund : ManualRefundRequest - Manual Refunds support is not enabled for the payment gateway. ");
            } else {
                if (manualRefundRequest.vaultedCard ?? nil != nil) {
                    if !merchantInfo.supportsVaultCards {
                        deviceObserver!.onFinishCancel(false, result:ResultCode.UNSUPPORTED, reason: "Invalid argument.", message: "In ManualRefund : ManualRefundRequest - VaultedCard support is not enabled for the payment gateway. ");
                    }
                } else {
                    let builder = PayIntent.Builder(amount:-1*Swift.abs(manualRefundRequest.amount), externalId: manualRefundRequest.externalId)
                    builder.vaultedCard = manualRefundRequest.vaultedCard
                    builder.cardEntryMethods = manualRefundRequest.cardEntryMethods ?? self.cardEntryMethods
                    builder.transactionType = TransactionType.CREDIT
                    builder.requiresRemoteConfirmation = true
                    var tx = CLVModels.Payments.TransactionSettings()
                    builder.transactionSettings = tx
                    
                    tx.cardEntryMethods = CloverConnector.CARD_ENTRY_METHOD_MAG_STRIPE | CloverConnector.CARD_ENTRY_METHOD_ICC_CONTACT | CloverConnector.CARD_ENTRY_METHOD_NFC_CONTACTLESS
                    tx.autoAcceptPaymentConfirmations = manualRefundRequest.autoAcceptPaymentConfirmations
                    tx.autoAcceptSignature = manualRefundRequest.autoAcceptSignature
                    tx.disableDuplicateCheck = manualRefundRequest.disableDuplicateChecking
                    tx.disableReceiptSelection = manualRefundRequest.disableReceiptSelection
                    tx.signatureEntryLocation = manualRefundRequest.signatureEntryLocation
                    
                    if let dp = manualRefundRequest.disablePrinting {
                        tx.cloverShouldHandleReceipts = !dp
                    }
                    
                    device.doTxStart(builder.build(), order: nil, suppressTipScreen: true)
                }
            }
        } else {
            deviceObserver!.onFinishCancel(false, result: ResultCode.ERROR, reason: "Device Connection Error", message: "In preAuth : The device is not connected.");
        }

    }
    
    public func voidPayment(_ request: VoidPaymentRequest) {
        
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "voidPayment: The Clover Device is not ready"));
                return;
            }
            let payment = CLVModels.Payments.Payment()
            
            payment.id = request.paymentId
            payment.order = CLVModels.Base.Reference()
            payment.order!.id = request.orderId
            payment.employee = CLVModels.Base.Reference()
            payment.employee!.id = ""
            
            device.doVoidPayment(payment, reason: request.voidReason.rawValue)
        } else {
            deviceObserver!.onPaymentVoided(false, result:ResultCode.ERROR, reason: "Device Connection Error", message: "In voidPayment : The device is not connected.");
        }
        

    }
    
    public func vaultCard(_ vaultCardRequest: VaultCardRequest) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "vaultCard: The Clover Device is not ready"));
                return;
            } else if merchantInfo.supportsVaultCards {
                device.doVaultCard(vaultCardRequest.cardEntryMethods ?? self.cardEntryMethods)
            } else {
                deviceObserver!.onVaultCardResponse(false, result: ResultCode.ERROR, reason: "Vault Card not supported", message: "In vaultCard: VaultCard support is not enabled for the payment gateway. ")
            }
        } else {
            deviceObserver!.onVaultCardResponse(false, result:ResultCode.UNSUPPORTED, reason: "Invalid argument.", message: "In VaultCard : VaultCard - VaultedCard support is not enabled for the payment gateway. ");
        }


    }
    
    public func closeout(_ closeoutRequest: CloseoutRequest) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "closeout: The Clover Device is not ready"));
                return;
            }
            device.doCloseout(closeoutRequest.allowOpenTabs, batchId: closeoutRequest.batchId)
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "In Closeout: The Clover Device is not connected"));
        }
        
    }
    
    public func displayPaymentReceiptOptions(_ orderId:String, paymentId:String) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "displayPaymentReceiptOptions: The Clover Device is not ready"));
                return;
            }
            device.doShowPaymentReceiptScreen(orderId, paymentId:paymentId);
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "In showPaymentReceiptOptions: The Clover Device is null"));
        }
    
    }
    
    @objc
    public func showMessage(_ message: String) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "showMessage: The Clover Device is not ready"));
                return;
            }
            device.doTerminalMessage(message)
            
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "showMessage: The Clover Device is null"));
        }

    }
    
    @objc
    public func printText(_ lines: [String]) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "printText: The Clover Device is not ready"));
                return;
            }
            device.doPrintText(lines)
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "printText: The Clover Device is null"));
        }
        
    }

    @objc
    public func printImageFromURL(_ url:String) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "printImageFromURL: The Clover Device is not ready"));
                return;
            }
            device.doPrintImage(url)
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "printImageFromURL: The Clover Device is null"));
        }
    }
    
    /*public func printImage(_ image: UIImage) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "printImage: The Clover Device is not ready"));
                return;
            }
            device.doPrintImage(image);
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "printImage: The Clover Device is null"));
        }

    }*/
    
    @objc
    public func cancel() {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "cancel: The Clover Device is not ready"));
                return;
            }
            device.doKeyPress(KeyPress.esc)
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "cancel: The Clover Device is null"));
        }

    }
    
    @objc
    public func openCashDrawer(_ reason:String) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "openCashDrawer: The Clover Device is not ready"));
                return;
            }
            device.doOpenCashDrawer(reason)
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "openCashDrawer: The Clover Device is null"));
        }

        
    }
    
    @objc
    public func resetDevice() {
        deviceObserver?.lastRequest = nil
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "resetDevice: The Clover Device is not ready"));
                return;
            }
            device.doBreak()
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "resetDevice: The Clover Device is null"));
        }
    }
    
    @objc
    public func showWelcomeScreen() {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "showWelcomeScreen: The Clover Device is not ready"));
                return;
            }
            device.doShowWelcomeScreen()
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "showWelcomeScreen: The Clover Device is null"));
        }

    }
    
    @objc
    public func showThankYouScreen() {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "showThankYouScreen: The Clover Device is not ready"));
                return;
            }
            device.doShowThankYouScreen()
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "showThankYouScreen: The Clover Device is null"));
        }

    }
    
    @objc
    public func showDisplayOrder(_ order: DisplayOrder) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "showDisplayOrder: The Clover Device is not ready"));
                return;
            }
            device.doOrderUpdate(order, orderOperation: nil)
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "showDisplayOrder: The Clover Device is null"));
        }

    }
    
    @objc
    public func removeDisplayOrder(_ order: DisplayOrder) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "removeDisplayOrder: The Clover Device is not ready"));
                return;
            }
            device.doOrderUpdate(DisplayOrder(), orderOperation: nil)
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "removeDisplayOrder: The Clover Device is null"));
        }
    }
    
    
    @objc
    public func invokeInputOption(_ inputOption:InputOption) {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "invokeInputOption: The Clover Device is not ready"));
                return;
            } else if let kp = inputOption.keyPress {
                device.doKeyPress(kp);
            } else {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.VALIDATION_ERROR, code: 0, message: "invokeInputOption: the keyPress is required"));
            }
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "invokeInputOption: The Clover Device is null"));
        }

    }

    public func notifyListenersDeviceError(_ configError:CloverDeviceErrorEvent) {
        broadcaster.notifyOnDeviceError(configError)
    }
    
    public func readCardData( _ request:ReadCardDataRequest ) -> Void {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "readCardData: The Clover Device is not ready"));
                return;
            }
            let builder:PayIntent.Builder = PayIntent.Builder(amount: 0, externalId: "\(arc4random())")
            if let cem:Int = request.cardEntryMethods {
                builder.cardEntryMethods = cem
            }
            builder.isForceSwipePinEntry = request.forceSwipePinEntry
            builder.transactionType = .DATA
            builder.requiresRemoteConfirmation = true
            
            device.doReadCardData(builder.build())
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "readCardData: The Clover Device is null"));
        }
    }
    
    public func acceptPayment( _ payment:CLVModels.Payments.Payment ) -> Void {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "readCardData: The Clover Device is not ready"));
                return;
            }
            device.doAcceptPayment(payment)
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "acceptPayment: The Clover Device is null"));
        }
    }
    
    public func rejectPayment( _ payment:CLVModels.Payments.Payment, challenge:Challenge ) -> Void {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "rejectPayment: The Clover Device is not ready"));
                return;
            }
            device.doRejectPayment(payment, challenge: challenge)
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "rejectPayment: The Clover Device is null"));
        }
    }
    
    public func retrievePendingPayments() -> Void {
        if let device = device {
            if !isReady {
                notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "retrievePendingPayments: The Clover Device is not ready"));
                return;
            }
            device.doRetrievePendingPayments();
        } else {
            notifyListenersDeviceError(CloverDeviceErrorEvent(errorType: CloverDeviceErrorType.COMMUNICATION_ERROR, code: 0, message: "retrievePendingPayments: The Clover Device is null"));
        }
    }

    class CloverConnectorDeviceObserver : CloverDeviceObserver {
        let cloverConnector:CloverConnector
        var lastRequest:AnyObject?
        var lastPRR:RefundPaymentResponse?
        
        public init(cloverConnector:CloverConnector) {
            self.cloverConnector = cloverConnector
        }
        
        func onAuthTipAdjustedResponse(_ paymentId: String, amount: Int, success: Bool) {
            onAuthTipAdjustedResponse(success, result: success ? ResultCode.SUCCESS : ResultCode.FAIL, reason: nil, message: nil, paymentId: paymentId, tipAmount: amount)
        }
        func onAuthTipAdjustedResponse(_ success: Bool, result: ResultCode, reason:String?, message:String?, paymentId: String?=nil, tipAmount: Int?=nil) {
            let taar = TipAdjustAuthResponse(success: success, result: result, paymentId: paymentId, tipAmount: tipAmount)
            taar.reason = reason
            taar.message = message
            cloverConnector.broadcaster.notifyOnTipAdjustAuthResponse(taar)
        }
        
        func onCapturePreAuthResponse(_ status: ResultStatus, reason: String, paymentId: String?, amount: Int?, tipAmount: Int?) {
            var success:Bool = false;
            switch(status) {
            case .SUCCESS: success = true; break
            default: success = false
            }
            onCapturePreAuthResponse(success, result: success ? ResultCode.SUCCESS : ResultCode.FAIL, reason: nil, message: nil, paymentId: paymentId, amount: amount, tipAmount: tipAmount)
        }
        func onCapturePreAuthResponse(_ success:Bool, result: ResultCode, reason: String?, message: String?, paymentId: String?=nil, amount: Int?=nil, tipAmount: Int?=nil) {
            let cpar = CapturePreAuthResponse(success: success, result: result, paymentId: paymentId, amount: amount, tipAmount: tipAmount)
            cpar.reason = reason
            cpar.message = message
            cloverConnector.broadcaster.notifyOnCapturePreAuth(cpar)
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
            if(cloverConnector.isReady ?? false) {
                cloverConnector.merchantInfo = MerchantInfo(id: discoveryResponseMessage.merchantId, mid: discoveryResponseMessage.merchantMId, name: discoveryResponseMessage.merchantName, deviceName: discoveryResponseMessage.name, deviceSerialNumber: discoveryResponseMessage.serial, deviceModel: discoveryResponseMessage.model)
                
                self.cloverConnector.broadcaster.notifyOnReady(cloverConnector.merchantInfo)
            } else {
                self.cloverConnector.broadcaster.notifyOnConnect();
            }
        }
        
        func onPaymentVoided(_ success: Bool, result:ResultCode, reason:String?, message:String?, payment: CLVModels.Payments.Payment?=nil, voidReason: VoidReason?=nil) {
            cloverConnector.device?.doShowWelcomeScreen()
            let response = VoidPaymentResponse(success:success, result: result, paymentId: payment?.id, transactionNumber: payment?.cardTransaction?.transactionNo)
            response.reason = reason
            response.message = message
            response.voidReason = voidReason
            cloverConnector.broadcaster.notifyOnVoidPaymentResponse(response);
        }
        
        func onPaymentVoidedResponse(_ payment: CLVModels.Payments.Payment, voidReason: VoidReason) {
            onPaymentVoided(true, result: ResultCode.SUCCESS, reason:nil, message:nil, payment:payment, voidReason: voidReason)
        }
        
        private func onVaultCardResponse(_ success:Bool, result:ResultCode, reason:String?, message:String?, vaultedCard:CLVModels.Payments.VaultedCard?=nil) {
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
        
        func onCloseoutResponse(_ code: ResultStatus, reason: String, batch: CLVModels.Payments.Batch) {
            let response = CloseoutResponse(batch: batch, success: code == .SUCCESS, result: code == .SUCCESS ? ResultCode.SUCCESS : ResultCode.FAIL)
            cloverConnector.broadcaster.notifyOnCloseoutResponse(response)
        }
        
        func onPaymentRefundResponse(_ orderId: String?, String paymentId: String?, refund: CLVModels.Payments.Refund?, code: TxState) {
            
            let success:Bool = code == TxState.SUCCESS
            let resultCode = success ? ResultCode.SUCCESS : ResultCode.FAIL
            lastPRR = RefundPaymentResponse(success: success, result:resultCode, orderId: orderId, paymentId: paymentId, refund: refund)
            // listener will be notified in onFinishOk
        }
        
        private func onFinishCancel(_ success: Bool, result:ResultCode, reason:String?, message:String?) {
            
            
            if let lastReq = lastRequest {
                lastRequest = nil
                if let lastReq = lastReq as? PreAuthRequest {
                    let preAuthResponse = PreAuthResponse(success: success, result: result)
                    preAuthResponse.reason = "Request Canceled";
                    preAuthResponse.reason = reason ?? reason
                    preAuthResponse.message = "PreAuth Request canceled by user"
                    preAuthResponse.message = message ?? message
                    preAuthResponse.payment = nil
                    cloverConnector.broadcaster.notifyOnPreAuthResponse(preAuthResponse);
                } else if let lastReq = lastReq as? SaleRequest {
                    let saleResponse = SaleResponse(success: success, result: result)
                    saleResponse.reason = "Request Canceled"
                    saleResponse.reason = reason ?? reason
                    saleResponse.message = "SaleRequest canceled by user"
                    saleResponse.message = message ?? message
                    saleResponse.payment = nil
                    cloverConnector.broadcaster.notifyOnSaleResponse(saleResponse);
                } else if let lastReq = lastReq as? AuthRequest {
                    let authResponse = AuthResponse(success: success, result: result)
                    authResponse.reason = "Request canceled"
                    authResponse.reason = reason ?? reason
                    authResponse.message = "AuthRequest canceled by user"
                    authResponse.message = message ?? message
                    authResponse.payment = nil
                    cloverConnector.broadcaster.notifyOnAuthResponse(authResponse);
                } else if let lastReq = lastReq as? ManualRefundRequest {
                    let refundResponse = ManualRefundResponse(success: success, result: result)
                    refundResponse.reason = "Request canceled"
                    refundResponse.reason = reason ?? reason
                    refundResponse.message = "ManualRefundRequest canceled by user"
                    refundResponse.message = message ?? message
                    cloverConnector.broadcaster.notifyOnManualRefundResponse(refundResponse);
                }

            } else if let lastPRRequest = lastPRR {
                cloverConnector.broadcaster.notifyOnPaymentRefundResponse(lastPRRequest);
                self.lastPRR = nil;
            }
            if let device = cloverConnector.device {
                device.doShowWelcomeScreen();
            }
        }

        func onFinishCancel() {
            onFinishCancel(false, result: ResultCode.CANCEL, reason: nil, message: nil)
        }
        
        func onFinishOk(_ credit: CLVModels.Payments.Credit) {
            lastRequest = nil
            let response = ManualRefundResponse(success: true, result: .SUCCESS, credit:credit, transactionNumber: credit.cardTransaction?.transactionNo)
            cloverConnector.broadcaster.notifyOnManualRefundResponse(response)
        }
        
        func onFinishOk(_ payment: CLVModels.Payments.Payment, signature: Signature?) {
            
            cloverConnector.device?.doShowWelcomeScreen() // doing this first allows the handlers to change the UI behavior

            if let lr = lastRequest {
                lastRequest = nil
                if let _lr = lr as? PreAuthRequest {
                    let response = PreAuthResponse(success:true, result:.SUCCESS);
                    response.payment = payment
                    response.signature = signature
                    cloverConnector.broadcaster.notifyOnPreAuthResponse(response);
                } else if let _lr = lr as? AuthRequest {
                    let response = AuthResponse(success:true, result:.SUCCESS)
                    response.payment = payment
                    response.signature = signature
                    cloverConnector.broadcaster.notifyOnAuthResponse(response)
                } else if let _lr = lr as? SaleRequest {
                    let response = SaleResponse(success:true, result:.SUCCESS)
                    response.payment = payment
                    response.signature = signature
                    cloverConnector.broadcaster.notifyOnSaleResponse(response)
                } else {
                    // this could be a problem, or this is from a re-issue receipt screen
                }
            } else {
                print("We have a finishOK without a last request")
            }

 
        }
        
        func onFinishOk(_ refund: CLVModels.Payments.Refund) {
            lastRequest = nil
            cloverConnector.device?.doShowWelcomeScreen();
                // Since finishOk is the more appropriate/consistent location in the "flow" to
                // publish the RefundResponse (like SaleResponse, AuthResponse, etc., rather
                // than after the server call, which calls onPaymetRefund),
                // we will hold on to the response from
                // onRefundResponse (Which has more information than just the refund) and publish it here
                if let _lastPRR = lastPRR {
                    self.lastPRR = nil
                    if _lastPRR.refund?.id == refund.id {
                        cloverConnector.broadcaster.notifyOnPaymentRefundResponse(_lastPRR);
                    } else {
                        // this refund doesn't match what we had!
                        // the last PaymentRefundResponse has a different refund that this refund in finishOk
                        // TODO:
                        print("no match: \(_lastPRR.refund?.id) vs \(refund.id)")
                    }
                } else {
                    // TODO: have a refund response in finishOk, but not one from onRefundResponse?
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
        
        func onTxStartResponse(_ result:TxStartResponseResult?, externalId:String) {
            if let result = result {
                let success:Bool = result == TxStartResponseResult.SUCCESS ? true : false;
                if (success)
                {
                    return
                }
                let duplicate:Bool = result == TxStartResponseResult.DUPLICATE
                
                if duplicate {
                    
                    if let lastR = self.lastRequest as? PreAuthRequest
                    {
                        let response:PreAuthResponse = PreAuthResponse(success:false, result:ResultCode.FAIL)
                        if (duplicate)
                        {
                            response.result = .CANCEL
                            response.reason = "\(result)"
                            response.message = "The provided transaction id of \(externalId) has already been processed and cannot be resubmitted."
                        }
                        else
                        {
                            response.result = .FAIL
                            response.reason = "\(result)"
                        }
                        cloverConnector.broadcaster.notifyOnPreAuthResponse(response);
                        self.lastRequest = nil
                    }
                    else if let lastR = self.lastRequest as? AuthRequest
                    {
                        let response:AuthResponse = AuthResponse(success:false, result:ResultCode.FAIL)
                        if (duplicate)
                        {
                            response.result = ResultCode.CANCEL
                            response.reason = "\(result)"
                            response.message = "The provided transaction id of \(externalId) has already been processed and cannot be resubmitted."
                        }
                        else
                        {
                            response.result = .FAIL
                            response.reason = "\(result)"
                        }
                        cloverConnector.broadcaster.notifyOnAuthResponse(response);
                        self.lastRequest = nil
                    }
                    else if let lastR = self.lastRequest as? SaleRequest
                    {
                        let response:SaleResponse = SaleResponse(success:false, result:ResultCode.FAIL);
                        if (duplicate)
                        {
                            response.result = .CANCEL
                            response.reason = "\(result)"
                            response.message = "The provided transaction id of \(externalId) has already been processed and cannot be resubmitted."
                        }
                        else
                        {
                            response.result = .FAIL
                            response.reason = "\(result)"
                        }
                        cloverConnector.broadcaster.notifyOnSaleResponse(response);
                    }
                    else if let lastR = self.lastRequest as? ManualRefundRequest
                    {
                        let response:ManualRefundResponse = ManualRefundResponse(success:false, result:ResultCode.FAIL)
                        if (duplicate)
                        {
                            response.result = .CANCEL
                            response.reason = "\(result)"
                            response.message = "The provided transaction id of \(externalId) has already been processed and cannot be resubmitted."
                        }
                        else
                        {
                            response.result = .FAIL
                            response.reason = "\(result)"
                        }
                        cloverConnector.broadcaster.notifyOnManualRefundResponse(response);
                    }
                }

            } else {
                return;
            }

        }
    
        func onUiState(_ uiState: UiState, uiText: String, uiDirection: UiState.UiDirection, inputOptions: [InputOption]?) {
            if(uiDirection == UiState.UiDirection.ENTER) {
                cloverConnector.broadcaster.notifyOnDeviceActivityStart(CloverDeviceEvent(eventState: "\(uiState)", message: uiText, inputOptions: inputOptions))
            } else if (uiDirection == UiState.UiDirection.EXIT) {
                cloverConnector.broadcaster.notifyOnDeviceActivityEnd(CloverDeviceEvent(eventState: "\(uiState)", message: uiText))
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
        
        func onPrintMerchantReceipt(_ payment: CLVModels.Payments.Payment?) {
            let printMerchant = PrintPaymentMerchantCopyReceiptMessage(payment: payment!)
            cloverConnector.broadcaster.notifyOnPrintMerchantReceipt(printMerchant)
        }
        
        func onPrintPayment(_ order: CLVModels.Order.Order?, payment: CLVModels.Payments.Payment?) {
            let printPayment = PrintPaymentReceiptMessage(payment: payment!, order: order!)
            cloverConnector.broadcaster.notifyOnPrintPaymentReceipt(printPayment)
        }
        
        func onPrintPaymentDecline(_ reason: String, payment: CLVModels.Payments.Payment?) {
            let printDecline = PrintPaymentDeclineReceiptMessage(payment: payment!, reason: reason)
            cloverConnector.broadcaster.notifyOnPrintPaymentDeclineReceipt(printDecline)
        }
        
        func onPrintRefundPayment(_ refund: CLVModels.Payments.Refund?, payment: CLVModels.Payments.Payment?, order: CLVModels.Order.Order?) {
            let printRefundPayment = PrintRefundPaymentReceiptMessage(payment: payment!, order: order!, refund: refund!)
            cloverConnector.broadcaster.notifyOnPrintPaymentRefund(printRefundPayment)
        }
        
        func onReadCardResponse(_ status: ResultStatus, reason: String, cardData: CardData?) {
            let rcdr = ReadCardDataResponse(success: status == .SUCCESS, result: status == .SUCCESS ? ResultCode.SUCCESS : ResultCode.CANCEL)
            rcdr.cardData = cardData
            
            cloverConnector.broadcaster.notifyOnReadCardResponse(rcdr);
        }
        
        func onTxStartResponse(_ result: TxStartResponseResult, externalId: String) {
            let success = result == TxStartResponseResult.SUCCESS ? true : false
            if (success)
            {
                return;
            }
            let duplicate = result == TxStartResponseResult.DUPLICATE
            
            if let _ = lastRequest as? PreAuthRequest
            {
                let response:PreAuthResponse = PreAuthResponse(success: false,result: ResultCode.FAIL);
                if (duplicate)
                {
                    response.result = ResultCode.CANCEL
                    response.reason = "\(result)"
                    response.message = "The provided transaction id of \(externalId) has already been processed and cannot be resubmitted."
                }
                else
                {
                    response.result = ResultCode.FAIL
                    response.reason = "\(result)"
                }
                cloverConnector.broadcaster.notifyOnPreAuthResponse(response);
            }
            else if let _ = lastRequest as? AuthRequest
            {
                let response = AuthResponse(success: false, result: ResultCode.FAIL);
                if (duplicate)
                {
                    response.result = ResultCode.CANCEL
                    response.reason = "\(result)"
                    response.message = "The provided transaction id of \(externalId) has already been processed and cannot be resubmitted."
                }
                else
                {
                    response.result = ResultCode.FAIL
                    response.reason = "\(result)"
                }
                cloverConnector.broadcaster.notifyOnAuthResponse(response);
            }
            else if let _ = lastRequest as? SaleRequest
            {
                let response = SaleResponse(success: false, result: ResultCode.FAIL);
                if (duplicate)
                {
                    response.result = ResultCode.CANCEL
                    response.reason  = "\(result)"
                    response.message = "The provided transaction id of \(externalId) has already been processed and cannot be resubmitted."
                }
                else
                {
                    response.result = ResultCode.FAIL
                    response.reason = "\(result)"
                }
                cloverConnector.broadcaster.notifyOnSaleResponse(response);
            }
            else if let _ = lastRequest as? ManualRefundRequest
            {
                let response = ManualRefundResponse(success: false, result: ResultCode.FAIL);
                if (duplicate)
                {
                    response.result = ResultCode.CANCEL
                    response.reason = "\(result)"
                    response.message = "The provided transaction id of \(externalId) has already been processed and cannot be resubmitted."
                }
                else
                {
                    response.result = ResultCode.FAIL
                    response.reason = "\(result)"
                }
                cloverConnector.broadcaster.notifyOnManualRefundResponse(response);
            }
            
        }
    }
}
