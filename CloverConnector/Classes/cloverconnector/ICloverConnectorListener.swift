
import Foundation
//import CloverSDKRemotepay

/*
 *  The CloverConnector API serves as the interface for connecting to a Clover device.
 *
 *  This document defines the available methods.
 */
public protocol ICloverConnectorListener : AnyObject {
    
    
    /// Called at the completion of a Sale() request. The SaleResponse contains a 
    /// ResultCode and a Success boolean. A successful Sale transaction will also have 
    /// the payment object, which can be for the full or partial amount of the Sale 
    /// request. 
    /// **Note:** A Sale transaction may come back as a tip-adjustable Auth, depending on 
    /// the payment gateway. The SaleResponse has a boolean isSale flag that 
    /// indicates whether the sale is final, or will be finalized during closeout.
    /// - Parameter response: The response to the transaction request.
    func  onSaleResponse ( _ response:SaleResponse ) -> Void 
    
    /// Called in response to an Auth() request. **Note:** An Auth transaction may come 
    /// back as a final Sale, depending on the payment gateway. The AuthResponse has 
    /// a boolean isAuth flag that indicates whether the Payment can still be      
    /// tip-adjusted.
    /// - Parameter authResponse: The response to the transaction request.
    func  onAuthResponse ( _ authResponse:AuthResponse ) -> Void
    
    /// Called in response to a PreAuth() request. **Note:** The boolean isPreAuth flag 
    /// in the PreAuthResponse indicates whether CapturePreAuth() can be called 
    /// for the returned Payment. If the isPreAuth flag is false and the isAuth flag is 
    /// true, then the payment gateway coerced the PreAuth() request to an Auth. 
    /// The payment will need to be voided or it will be automatically captured at 
    /// closeout.
    /// - Parameter preAuthResponse: The response to the transaction request.
    func  onPreAuthResponse ( _ preAuthResponse:PreAuthResponse ) -> Void
    
    /// Called in response to a CapturePreAuth() request. 
    /// Contains the new Amount and TipAmount if successful.
    /// - Parameter capturePreAuthResponse: The response to the transaction request.
    func  onCapturePreAuthResponse ( _ capturePreAuthResponse:CapturePreAuthResponse ) -> Void
    
    /// Called in response to an `incrementPreAuth()` call on the CloverConnector
    /// Returns the incremented pre-auth, if successful
    /// - Parameter incrementPreAuthResponse: The response to the pre-auth increment request.
    func onIncrementPreAuthResponse(_ incrementPreAuthResponse: IncrementPreauthResponse) -> Void
    
    /// Called in response to a tip adjustment for an Auth transaction. 
    /// Contains the tipAmount if successful.
    /// - Parameter tipAdjustAuthResponse: The response to the transaction request.
    func  onTipAdjustAuthResponse ( _ tipAdjustAuthResponse:TipAdjustAuthResponse ) -> Void 
    
    /// Called in response to a voidPayment() request. Contains a 
    /// [ResultCode](https://clover.github.io/remote-pay-ios/4.0.0/docs/Enums/ResultCode.html)
    /// and a Success boolean. If successful, the response will also contain the
    /// paymentId for the voided Payment.
    /// - Parameter voidPaymentResponse: The response to the transaction request.
    func  onVoidPaymentResponse ( _ voidPaymentResponse:VoidPaymentResponse ) -> Void
    
    /// Called in response to a RefundPayment() request. Contains a 
    /// [ResultCode](https://clover.github.io/remote-pay-ios/4.0.0/docs/Enums/ResultCode.html)
    /// and a Success boolean. The response to a successful transaction will contain the 
    /// Refund. The Refund includes the original paymentId as a reference.
    /// - Parameter refundPaymentResponse: The response to the transaction request.
    func  onRefundPaymentResponse ( _ refundPaymentResponse:RefundPaymentResponse ) -> Void
    
    /// Called in response to a voidPaymentRefund() request. Contains a
    /// [ResultCode](https://clover.github.io/remote-pay-ios/4.0.0/docs/Enums/ResultCode.html)
    /// and a Success boolean. The response to a successful transaction will contain the
    /// Refund. The Refund includes the original paymentId as a reference.
    /// - Parameter VoidPaymentRefundResponse: The response to the transaction request.
    func onVoidPaymentRefundResponse(_ response: VoidPaymentRefundResponse) -> Void
    
    /// Called in response to a manualRefund() request. Contains a 
    /// [ResultCode](https://clover.github.io/remote-pay-ios/4.0.0/docs/Enums/ResultCode.html)
    /// and a Success boolean. If successful, the ManualRefundResponse will have 
    /// a Credit object associated with the relevant Payment information.
    /// - Parameter manualRefundResponse: The response to the transaction request.
    func  onManualRefundResponse ( _ manualRefundResponse:ManualRefundResponse ) -> Void  
    
    /// Called in response to a Closeout() request.
    /// - Parameter closeoutResponse: The response to the transaction request.
    func  onCloseoutResponse ( _ closeoutResponse:CloseoutResponse ) -> Void
    
    /// Called when the Clover device requests verification for a user's on-screen 
    /// signature. The Payment and Signature will be passed in.
    /// - Parameter signatureVerifyRequest: The verification request.
    func  onVerifySignatureRequest ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void
    
    /// Called in response to a vaultCard() request. Contains a 
    /// [ResultCode](https://clover.github.io/remote-pay-ios/4.0.0/docs/Enums/ResultCode.html) 
    /// and a Success boolean. If successful, the response will contain a VaultedCard 
    /// object with a token value that's unique for the card and merchant. The token
    /// can be used for future Sale() and Auth() requests.
    /// - Parameter vaultCardResponse: The response to the request.
    func  onVaultCardResponse ( _ vaultCardResponse:VaultCardResponse ) -> Void
    
    /// Called when the Clover device transitions to a new screen or activity. 
    /// The CloverDeviceEvent passed in will contain an event type, a description, 
    /// and a list of available InputOptions.
    /// - Parameter deviceEvent: The device event.
    func onDeviceActivityStart( _ deviceEvent: CloverDeviceEvent ) -> Void
    
    /// Called when the Clover device transitions away from a screen or activity. 
    /// The CloverDeviceEvent passed in will contain an event type and description. 
    /// **Note:** The start and end events are not guaranteed to process in order. 
    /// The event type should be used to make sure these events are paired.
    /// - Parameter deviceEvent: The device event.
    func onDeviceActivityEnd( _ deviceEvent: CloverDeviceEvent ) -> Void
    
    /// Called when an error occurs while trying to send messages to the Clover 
    /// device.
    /// - Parameter deviceErrorEvent: The device error event.
    func onDeviceError( _ deviceErrorEvent: CloverDeviceErrorEvent ) -> Void
    
    /// Called when the Clover device is initially connected, but not ready to 
    /// communicate.
    func  onDeviceConnected () -> Void
    
    /// Called when the Clover device is ready to communicate and respond to requests.
    /// - Parameter merchantInfo: The merchant information to associate with the device.
    func  onDeviceReady (_ merchantInfo: MerchantInfo) -> Void
    
    /// Called when the Clover device is disconnected from the CloverConnector or not 
    /// responding. Not called when the CloverConnector is manually disconnected via 'dispose()'
    func  onDeviceDisconnected () -> Void
    
    /// Called when the Clover device encounters a Challenge at the payment gateway 
    /// and requires confirmation. A Challenge is triggered by a potential 
    /// duplicate Payment (DUPLICATE_CHALLENGE) or an offline Payment 
    /// (OFFLINE_CHALLENGE). The device sends a ConfirmPaymentRequest() 
    /// asking the merchant to reply by sending either an AcceptPayment() or 
    /// RejectPayment() call.
    /// 
    /// Note that duplicate Payment Challenges are raised when multiple Payments 
    /// are made with the same card type and last four digits within the same hour. 
    /// For this reason, we recommend that you do not programmatically call 
    /// CloverConnector.RejectPayment() on all instances of DUPLICATE_CHALLENGE. 
    /// For more information, see [Working with 
    /// Challenges](https://docs.clover.com/build/working-with-challenges/). 
    /// - Parameter request: The request for confirmation.
    func onConfirmPaymentRequest(_ request:ConfirmPaymentRequest) -> Void
    
    /// Called when a customer selects a tip amount on the Clover device's screen.
    /// - Parameter message: The TipAddedMessage.
    func onTipAdded(_ message:TipAddedMessage) -> Void  
    
    /// Called when a user requests a paper receipt for a Manual Refund. Will only be 
    /// called if disablePrinting = true on the ManualRefund() request.
    /// - Parameter printManualRefundReceiptMessage: A callback that asks the POS to print a receipt for a ManualRefund. Contains a Credit object.
    func onPrintManualRefundReceipt(_ printManualRefundReceiptMessage:PrintManualRefundReceiptMessage) -> Void

    /// Called when a user requests a paper receipt for a declined Manual Refund. Will 
    /// only be called if disablePrinting = true on the ManualRefund() request.
    /// - Parameter printManualRefundDeclineReceiptMessage: The PrintManualRefundDeclineReceiptMessage.
    func onPrintManualRefundDeclineReceipt(_ printManualRefundDeclineReceiptMessage:PrintManualRefundDeclineReceiptMessage) -> Void
    
    /// Called when a user requests a paper receipt for a Payment. Will only be called if
    /// disablePrinting = true on the Sale(), Auth(), or PreAuth() request.
    ///  - Parameter printPaymentReceiptMessage: The message.
    func onPrintPaymentReceipt(_ printPaymentReceiptMessage:PrintPaymentReceiptMessage)
    
    /// Called when a user requests a paper receipt for a declined Payment.  Will only be 
    /// called if disablePrinting = true on the Sale(), Auth(), or PreAuth() request.
    /// - Parameter printPaymentDeclineReceiptMessage: The message.
    func onPrintPaymentDeclineReceipt(_ printPaymentDeclineReceiptMessage:PrintPaymentDeclineReceiptMessage)
    
    /// Called when a user requests a merchant copy of a Payment receipt. Will only be 
    /// called if disablePrinting = true on the Sale(), Auth(), or PreAuth() request.
    /// - Parameter printPaymentMerchantCopyReceiptMessage: The message.
    func onPrintPaymentMerchantCopyReceipt(_ printPaymentMerchantCopyReceiptMessage:PrintPaymentMerchantCopyReceiptMessage) -> Void
    
    /// Called when a user requests a paper receipt for a Payment Refund. Will only be 
    /// called if disablePrinting = true on the Sale(), Auth(), PreAuth() or 
    /// ManualRefund() request.
    /// - Parameter printRefundPaymentReceiptMessage: The message.
    func onPrintRefundPaymentReceipt(_ printRefundPaymentReceiptMessage:PrintRefundPaymentReceiptMessage) -> Void
    
    /// Called in response to a retrievePrinters() request.
    ///
    /// - Parameter retrievePrintersResponse: The response to the request.
    func onRetrievePrintersResponse(_ retrievePrintersResponse:RetrievePrintersResponse) -> Void
    
    /// Called in response to a retrievePrintJobStatus() request.
    ///
    /// - Parameter printJobStatusResponse: The response to the request.
    func onPrintJobStatusResponse(_ printJobStatusResponse:PrintJobStatusResponse) -> Void
    
    /// Called in response to a retrievePendingPayment() request.
    /// - Parameter retrievePendingPaymentResponse: The response to the request.
    func onRetrievePendingPaymentsResponse(_ retrievePendingPaymentResponse:RetrievePendingPaymentsResponse) -> Void
    
    /// Called in response to a readCardData() request.
    /// - Parameter readCardDataResponse: The response to the request.
    func onReadCardDataResponse(_ readCardDataResponse:ReadCardDataResponse) -> Void
    
    /// Called when a Custom Activity finishes normally.
    /// - Parameter customActivityResponse: The CustomActivityResponse.
    func onCustomActivityResponse(_ customActivityResponse:CustomActivityResponse) -> Void
    
    /// Called in response to a ResetDevice() request.
    /// - Parameter response: The response to the request.
    func onResetDeviceResponse(_ response:ResetDeviceResponse) -> Void
    
    /// Called whenever customer provided data is accrued via the Loyalty API.
    /// Call the registerForCustomerProvidedData to request that this message be called.
    func onCustomerProvidedDataEvent(_ event:CustomerProvidedDataEvent) -> Void
    
    /// Called when a Custom Activity sends a message to the POS.
    /// - Parameter response: The message.
    func onMessageFromActivity(_ response:MessageFromActivity) -> Void
    
    /// Called in response to a RetrievePayment() request.
    /// - Parameter response: The response to the request.
    func onRetrievePaymentResponse(_ response:RetrievePaymentResponse) -> Void
    
    /// Called in response to a RetrieveDeviceStatus() request.
    /// - Parameter response: The response to the request.
    func onRetrieveDeviceStatusResponse(_ response: RetrieveDeviceStatusResponse) -> Void
    
    /// Called in response to a request that results in an invalid kiosk flow transition
    /// - Parameter response: The invalid state transition response
    func onInvalidStateTransitionResponse(_ response: InvalidStateTransitionResponse) -> Void
    
    /// Called in response to a DisplayReceiptOptionsRequest
    ///
    /// - Parameter response: Response object of type DisplayReceiptOptionsResponse
    func onDisplayReceiptOptionsResponse(_ response: DisplayReceiptOptionsResponse) -> Void
}
