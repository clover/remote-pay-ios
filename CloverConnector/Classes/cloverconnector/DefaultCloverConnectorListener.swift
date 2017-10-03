//
//  DefaultCloverConnectorListener.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation


open class DefaultCloverConnectorListener : NSObject, ICloverConnectorListener {
   
    public weak var cloverConnector:ICloverConnector?
    
    public init(cloverConnector:ICloverConnector?) {
        self.cloverConnector = cloverConnector
    }

    
    
    public func onTipAdded(_ message: TipAddedMessage) {}
    
    /*
     * Response to a sale request.
     */
    open func  onSaleResponse ( _ response:SaleResponse ) -> Void {}
    
    
    /*
     * Response to an authorization operation.
     */
    open func  onAuthResponse ( _ authResponse:AuthResponse ) -> Void {}
    
    
    /*
     * Response to a preauth operation.
     */
    open func  onPreAuthResponse ( _ preAuthResponse:PreAuthResponse ) -> Void {}
    
    
    /*
     * Response to a preauth being captured.
     */
    open func  onCapturePreAuthResponse ( _ capturePreAuthResponse:CapturePreAuthResponse ) -> Void {}
    
    
    /*
     * Response to a tip adjustment for an auth.
     */
    open func  onTipAdjustAuthResponse ( _ tipAdjustAuthResponse:TipAdjustAuthResponse ) -> Void {}
    
    
    /*
     * Response to a payment be voided.
     */
    open func  onVoidPaymentResponse ( _ voidPaymentResponse:VoidPaymentResponse ) -> Void {}
    
    
    /*
     * Response to a credit being voided.
     */
    open func  onVoidCreditResponse ( _ voidCreditResponse:VoidCreditResponse ) -> Void {}
    
    
    /*
     * Response to a payment being refunded.
     */
    open func onRefundPaymentResponse(_ refundPaymentResponse: RefundPaymentResponse) -> Void {}
    
    
    /*
     * Response to an amount being refunded.
     */
    open func onManualRefundResponse ( _ manualRefundResponse:ManualRefundResponse ) -> Void {}
    
    
    /*
     * Response to a closeout.
     */
    open func onCloseoutResponse ( _ closeoutResponse:CloseoutResponse ) -> Void {}
    
    
    /*
     * Receives signature verification requests.
     */
    open func  onVerifySignatureRequest ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void {
        if let cc = cloverConnector {
            cc.acceptSignature(signatureVerifyRequest);
        }
    }
    
    
    /*
     * Response to vault a card.
     */
    open func  onVaultCardResponse ( _ vaultCardResponse:VaultCardResponse ) -> Void {}
    
    /*
     *
     */
    
    open func onDeviceActivityStart( _ deviceEvent: CloverDeviceEvent ) -> Void {}
    
    open func onDeviceActivityEnd( _ deviceEvent: CloverDeviceEvent ) -> Void {}
    
    open func onDeviceError( _ deviceError: CloverDeviceErrorEvent ) -> Void {}
    
    
    
    /*
     * called when the device is initially connected
     */
    open func  onDeviceConnected () -> Void {}
    
    
    /*
     * called when the device is ready to communicate
     */
    open func  onDeviceReady (_ merchantInfo: MerchantInfo) -> Void {}
    
    
    /*
     * called when the device is disconnected, or not responding
     */
    open func  onDeviceDisconnected () -> Void {}
    
    /*
     * callbacks if disablePrinting is enabled on the request
     */
    
    open func onPrintManualRefundReceipt(_ pcm:PrintManualRefundReceiptMessage){}
    
    open func onPrintManualRefundDeclineReceipt(_ pcdrm:PrintManualRefundDeclineReceiptMessage){}
    
    open func onPrintPaymentReceipt(_ pprm:PrintPaymentReceiptMessage){}
    
    open func onPrintPaymentDeclineReceipt(_ ppdrm:PrintPaymentDeclineReceiptMessage){}
    
    open func onPrintPaymentMerchantCopyReceipt(_ ppmcrm:PrintPaymentMerchantCopyReceiptMessage){}
    
    open func onPrintRefundPaymentReceipt(_ pprrm:PrintRefundPaymentReceiptMessage){}
    
    open func onRetrievePendingPaymentsResponse(_ retrievePendingPaymentResponse:RetrievePendingPaymentsResponse){}
    
    open func onReadCardDataResponse(_ readCardDataResponse: ReadCardDataResponse) {}
    
    open func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {}
    
    open func onCustomActivityResponse(_ customActivityResponse: CustomActivityResponse) {}
    
    open func onMessageFromActivity(_ response: MessageFromActivity) {}
    
    open func onResetDeviceResponse(_ response: ResetDeviceResponse) {}

    open func onRetrievePaymentResponse(_ response: RetrievePaymentResponse) {}
    
    open func onRetrievePrintersResponse(_ response: RetrievePrintersResponse) {}
    
    open func onPrintJobStatusResponse(_ printJobStatusResponse:PrintJobStatusResponse) {}

    open func onRetrieveDeviceStatusResponse(_ _response: RetrieveDeviceStatusResponse) {}
}
