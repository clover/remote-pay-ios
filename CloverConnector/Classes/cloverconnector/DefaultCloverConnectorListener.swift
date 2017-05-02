//
//  DefaultCloverConnectorListener.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation


@objc
public class DefaultCloverConnectorListener : NSObject, ICloverConnectorListener {
   
    public var cloverConnector:ICloverConnector?
    
    public init(cloverConnector:ICloverConnector?) {
        self.cloverConnector = cloverConnector
    }

    
    
    public func onTipAdded(_ message: TipAddedMessage) {}
    
    /*
     * Response to a sale request.
     */
    public func  onSaleResponse ( _ response:SaleResponse ) -> Void {}
    
    
    /*
     * Response to an authorization operation.
     */
    public func  onAuthResponse ( _ authResponse:AuthResponse ) -> Void {}
    
    
    /*
     * Response to a preauth operation.
     */
    public func  onPreAuthResponse ( _ preAuthResponse:PreAuthResponse ) -> Void {}
    
    
    /*
     * Response to a preauth being captured.
     */
    public func  onCapturePreAuthResponse ( _ capturePreAuthResponse:CapturePreAuthResponse ) -> Void {}
    
    
    /*
     * Response to a tip adjustment for an auth.
     */
    public func  onTipAdjustAuthResponse ( _ tipAdjustAuthResponse:TipAdjustAuthResponse ) -> Void {}
    
    
    /*
     * Response to a payment be voided.
     */
    public func  onVoidPaymentResponse ( _ voidPaymentResponse:VoidPaymentResponse ) -> Void {}
    
    
    /*
     * Response to a credit being voided.
     */
    public func  onVoidCreditResponse ( _ voidCreditResponse:VoidCreditResponse ) -> Void {}
    
    
    /*
     * Response to a payment being refunded.
     */
    public func onRefundPaymentResponse(_ refundPaymentResponse: RefundPaymentResponse) -> Void {}
    
    
    /*
     * Response to an amount being refunded.
     */
    public func onManualRefundResponse ( _ manualRefundResponse:ManualRefundResponse ) -> Void {}
    
    
    /*
     * Response to a closeout.
     */
    public func onCloseoutResponse ( _ closeoutResponse:CloseoutResponse ) -> Void {}
    
    
    /*
     * Receives signature verification requests.
     */
    public func  onVerifySignatureRequest ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void {
        if let cc = cloverConnector {
            cc.acceptSignature(signatureVerifyRequest);
        }
    }
    
    
    /*
     * Response to vault a card.
     */
    public func  onVaultCardResponse ( _ vaultCardResponse:VaultCardResponse ) -> Void {}
    
    /*
     *
     */
    
    public func onDeviceActivityStart( _ deviceEvent: CloverDeviceEvent ) -> Void {}
    
    public func onDeviceActivityEnd( _ deviceEvent: CloverDeviceEvent ) -> Void {}
    
    public func onDeviceError( _ deviceError: CloverDeviceErrorEvent ) -> Void {}
    
    
    
    /*
     * called when the device is initially connected
     */
    public func  onDeviceConnected () -> Void {}
    
    
    /*
     * called when the device is ready to communicate
     */
    public func  onDeviceReady (_ merchantInfo: MerchantInfo) -> Void {}
    
    
    /*
     * called when the device is disconnected, or not responding
     */
    public func  onDeviceDisconnected () -> Void {}
    
    /*
     * callbacks if disablePrinting is enabled on the request
     */
    
    public func onPrintManualRefundReceipt(_ pcm:PrintManualRefundReceiptMessage){}
    
    public func onPrintManualRefundDeclineReceipt(_ pcdrm:PrintManualRefundDeclineReceiptMessage){}
    
    public func onPrintPaymentReceipt(_ pprm:PrintPaymentReceiptMessage){}
    
    public func onPrintPaymentDeclineReceipt(_ ppdrm:PrintPaymentDeclineReceiptMessage){}
    
    public func onPrintPaymentMerchantCopyReceipt(_ ppmcrm:PrintPaymentMerchantCopyReceiptMessage){}
    
    public func onPrintRefundPaymentReceipt(_ pprrm:PrintRefundPaymentReceiptMessage){}
    
    public func onRetrievePendingPaymentsResponse(_ retrievePendingPaymentResponse:RetrievePendingPaymentsResponse){}
    
    public func onReadCardDataResponse(_ readCardDataResponse: ReadCardDataResponse) {}
    
    public func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
        fatalError("Must be implemented!")
    }
    
}
