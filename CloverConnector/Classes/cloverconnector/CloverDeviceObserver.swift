//
//  CloverDeviceObserver.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK


protocol CloverDeviceObserver:AnyObject {
    
    //    func onTxState(TxState txState)
    
    func onUiState(_ uiState:UiState, uiText:String, uiDirection:UiState.UiDirection, inputOptions:[InputOption]?)
    
    func onTipAddedResponse(_ tipAmount:Int)
    
    func onAuthTipAdjustedResponse(_ paymentId:String, amount:Int, success:Bool)
    
    func onCashbackSelectedResponse(_ cashbackAmount:Int)
    
    func onPartialAuthResponse(_ partialAuthAmount:Int)
    
    func onFinishOk(_ payment:CLVModels.Payments.Payment, signature:Signature?, requestInfo:String?)
    
    func onFinishOk(_ credit:CLVModels.Payments.Credit)
    
    func onFinishOk(_ redund:CLVModels.Payments.Refund, requestInfo:String?)
    
    func onFinishCancel(_ requestInfo:String?)
    
    func onVerifySignature(_ payment:CLVModels.Payments.Payment, signature:Signature?)
    
    func onPaymentVoidedResponse(_ payment:CLVModels.Payments.Payment, voidReason:VoidReason)
    
    func onKeyPressed(_ keyPress:KeyPress)
    
    func onPaymentRefundResponse(_ orderId:String?, paymentId:String?, refund:CLVModels.Payments.Refund?, reason:ErrorCode?, message:String?, code:TxState)
    
    func onVaultCardResponse( _ vaultedCard:CLVModels.Payments.VaultedCard?, code:ResultStatus?, reason:String?)
    
    func onCapturePreAuthResponse( _ status:ResultStatus, reason:String, paymentId:String?, amount:Int?, tipAmount:Int?)
    
    func onCloseoutResponse( _ status:ResultStatus, reason:String, batch:CLVModels.Payments.Batch)
    
    //func onModifyOrder(AddDiscountAction addDiscountAction)
    //func onModifyOrder(RemoveDiscountAction removeDiscountAction)
    //func onModifyOrder(AddLineItemAction addLineItemAction)
    //func onModifyOrder(RemoveLineItemAction removeLineItemAction)
    
    func onPrintRefundPayment(_ refund:CLVModels.Payments.Refund, payment:CLVModels.Payments.Payment, order:CLVModels.Order.Order)
    func onPrintMerchantReceipt(_ payment:CLVModels.Payments.Payment)
    func onPrintPaymentDecline(_ reason:String, payment:CLVModels.Payments.Payment)
    func onPrintPayment(_ order:CLVModels.Order.Order, payment:CLVModels.Payments.Payment)
    func onPrintCredit(_ credit:CLVModels.Payments.Credit)
    func onPrintCreditDecline(_ reason:String, credit:CLVModels.Payments.Credit?)
    
    func onTxStartResponse(_ result:TxStartResponseResult, externalId:String, requestInfo: String?)
    
    func onDeviceDisconnected( _ device:CloverDevice)
    func onDeviceConnected(_ device:CloverDevice)
    func onDeviceReady(_ device:CloverDevice, discoveryResponseMessage:DiscoveryResponseMessage)
    
    /// Device experienced an error on the transport
    ///
    /// - Parameters:
    ///   - errorType: Type of the CloverDeviceErrorType being thrown
    ///   - int: Code from the NSError experienced earlier in the flow
    ///   - message: LocalizedDescription from the NSError experienced earlier in the flow
    func onDeviceError(_ errorType:CloverDeviceErrorType, int:Int?, cause:Error?, message:String)
    
    func onMessageAck(_ sourceMessageId:String)
    
    func onPendingPaymentsResponse(_ success:Bool, payments:[PendingPaymentEntry]?)
    
    func onReadCardResponse( _ status:ResultStatus, reason:String, cardData:CardData?)
    func onConfirmPayment(_ payment:CLVModels.Payments.Payment?, challenges: [Challenge]?)
    func onActivityResponse(_ status:ResultCode, action:String?, payload:String?, failReason: String?)
    func onDeviceStatusResponse(_ result:ResultStatus, reason: String?, state: ExternalDeviceState, subState: ExternalDeviceSubState?, data: ExternalDeviceStateData?)
    func onMessageFromActivity(_ action: String, payload: String?)
    func onRetrievePaymentResponse(_ result: ResultStatus, reason:String?, queryStatus: QueryStatus, payment:CLVModels.Payments.Payment?, externalPaymentId:String?)
    func onRetrievePrintersResponse(_ printers:[CLVModels.Printer.Printer]?)
    func onRetrievePrintJobStatus(_ printRequestId:String?, status:String?)
    func onResetDeviceResponse(_ result:ResultStatus, reason: String?, state: ExternalDeviceState)
}

public class DefaultCloverDeviceObserver : CloverDeviceObserver {
    func onUiState(_ uiState:UiState, uiText:String, uiDirection:UiState.UiDirection, inputOptions:[InputOption]?){}
    
    func onTipAddedResponse(_ tipAmount:Int){}
    
    func onAuthTipAdjustedResponse(_ paymentId:String, amount:Int, success:Bool){}
    
    func onCashbackSelectedResponse(_ cashbackAmount:Int){}
    
    func onPartialAuthResponse(_ partialAuthAmount:Int){}
    
    func onFinishOk(_ payment:CLVModels.Payments.Payment, signature:Signature?, requestInfo:String?){}
    
    func onFinishOk(_ credit:CLVModels.Payments.Credit){}
    
    func onFinishOk(_ redund:CLVModels.Payments.Refund, requestInfo:String?){}
    
    func onFinishCancel(_ requestInfo:String?){}
    
    func onVerifySignature(_ payment:CLVModels.Payments.Payment, signature:Signature?){}
    
    func onPaymentVoidedResponse(_ payment:CLVModels.Payments.Payment, voidReason:VoidReason){}
    
    func onKeyPressed(_ keyPress:KeyPress){}
    
    func onPaymentRefundResponse(_ orderId:String?, paymentId:String?, refund:CLVModels.Payments.Refund?, reason:ErrorCode?, message:String?, code:TxState){}
    
    func onVaultCardResponse( _ vaultedCard:CLVModels.Payments.VaultedCard?, code:ResultStatus?, reason:String?){}
    
    func onCapturePreAuthResponse( _ status:ResultStatus, reason:String, paymentId:String?, amount:Int?, tipAmount:Int?){}
    
    func onCloseoutResponse( _ status:ResultStatus, reason:String, batch:CLVModels.Payments.Batch){}
    
    //func onModifyOrder(AddDiscountAction addDiscountAction)
    //func onModifyOrder(RemoveDiscountAction removeDiscountAction)
    //func onModifyOrder(AddLineItemAction addLineItemAction)
    //func onModifyOrder(RemoveLineItemAction removeLineItemAction)
    
    func onPrintRefundPayment(_ refund:CLVModels.Payments.Refund, payment:CLVModels.Payments.Payment, order:CLVModels.Order.Order){}
    func onPrintMerchantReceipt(_ payment:CLVModels.Payments.Payment){}
    func onPrintPaymentDecline(_ reason:String, payment:CLVModels.Payments.Payment){}
    func onPrintPayment(_ order:CLVModels.Order.Order, payment:CLVModels.Payments.Payment){}
    func onPrintCredit(_ credit:CLVModels.Payments.Credit){}
    func onPrintCreditDecline(_ reason:String, credit:CLVModels.Payments.Credit?){}
    
    func onTxStartResponse(_ result:TxStartResponseResult, externalId:String, requestInfo: String?){}
    
    func onDeviceDisconnected( _ device:CloverDevice){}
    func onDeviceConnected(_ device:CloverDevice){}
    func onDeviceReady(_ device:CloverDevice, discoveryResponseMessage:DiscoveryResponseMessage){}
    func onDeviceError(_ errorType:CloverDeviceErrorType, int:Int?, cause:Error?, message:String){}
    
    func onMessageAck(_ sourceMessageId:String){}
    
    func onPendingPaymentsResponse(_ success:Bool, payments:[PendingPaymentEntry]?){}
    
    func onReadCardResponse( _ status:ResultStatus, reason:String, cardData:CardData?){}
    func onConfirmPayment(_ payment:CLVModels.Payments.Payment?, challenges: [Challenge]?){}
    
    func onActivityResponse(_ status:ResultCode, action:String?, payload:String?, failReason: String?) {}
    
    func onDeviceStatusResponse(_ result:ResultStatus, reason: String?, state: ExternalDeviceState, subState: ExternalDeviceSubState?, data: ExternalDeviceStateData?) {}
    func onMessageFromActivity(_ action: String, payload: String?){}
    func onRetrievePaymentResponse(_ result: ResultStatus, reason:String?, queryStatus: QueryStatus, payment:CLVModels.Payments.Payment?, externalPaymentId:String?){}
    func onRetrievePrintersResponse(_ printers:[CLVModels.Printer.Printer]?) {}
    func onRetrievePrintJobStatus(_ printRequestId:String?, status:String?) {}
    func onResetDeviceResponse(_ result:ResultStatus, reason: String?, state: ExternalDeviceState){}
}
