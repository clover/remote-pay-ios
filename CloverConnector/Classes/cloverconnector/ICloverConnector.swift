import Foundation

///
///  Interface to the Clover remote-pay API.
///
///  Defines the interface used to interact with remote pay
///  adapters.
///
public protocol ICloverConnector : AnyObject {
    
    var CARD_ENTRY_METHOD_MAG_STRIPE:Int { get }
    var CARD_ENTRY_METHOD_ICC_CONTACT:Int { get }
    var CARD_ENTRY_METHOD_NFC_CONTACTLESS:Int { get }
    var CARD_ENTRY_METHOD_MANUAL:Int { get }
    
    var CARD_ENTRY_METHODS_DEFAULT:Int { get }
    
    var MAX_PAYLOAD_SIZE:Int { get }

    
    
    func addCloverConnectorListener(_ cloverConnectorListener:ICloverConnectorListener) -> Void
    func removeCloverConnectorListener(_ cloverConnectorListener:ICloverConnectorListener) -> Void
    
    ///
    /// Must be called to initialize the connection to the Clover device before calling any other methods
    /// on ICloverConnector
    ///
    func initializeConnection() -> Void
    /**
     Request a sale operation.
     parameter: SaleRequest
     */
    func  sale ( _ saleRequest:SaleRequest ) -> Void
    
    
    ///
    /// Request an authorization operation.
    ///
    func  auth ( _ authRequest:AuthRequest ) -> Void
    
    
    ///
    /// Request a preauth operation.
    ///
    func  preAuth ( _ preAuthRequest:PreAuthRequest ) -> Void
    
    
    ///
    /// Request a preauth be captured.
    ///
    func  capturePreAuth ( _ capturePreAuthRequest:CapturePreAuthRequest ) -> Void
    
    
    ///
    /// Request a tip adjustment to an auth.
    ///
    func  tipAdjustAuth ( _ authTipAdjustRequest:TipAdjustAuthRequest ) -> Void
    
    
    ///
    /// Request a payment be voided.
    ///
    func  voidPayment ( _ voidPaymentRequest:VoidPaymentRequest ) -> Void
    
    
    ///
    /// Request a payment be refunded.
    ///
    func  refundPayment ( _ refundPaymentRequest:RefundPaymentRequest ) -> Void
    
    
    ///
    /// Request an amount be refunded.
    ///
    func  manualRefund ( _ manualRefundRequest:ManualRefundRequest ) -> Void
    
    
    ///
    /// Request a cancel be sent to the device.
    ///
    /// Use resetDevice() or invokeInputOption() with the screen appropriate options instead.
    ///
    ///
    @available(*, deprecated)
    func  cancel () -> Void
    
    
    ///
    /// Request a closeout.
    ///
    func  closeout ( _ closeoutRequest:CloseoutRequest ) -> Void
    
    
    ///
    /// Request receipt options be displayed for a payment.
    ///
    func displayPaymentReceiptOptions(orderId:String, paymentId: String) -> Void
    
    
    ///
    /// Accept a signature verification request.
    ///
    func  acceptSignature ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void
    
    
    ///
    /// Reject a signature verification request.
    ///
    func  rejectSignature ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void
    
    
    ///
    /// Request to vault a card.
    ///
    func  vaultCard ( _ vaultCardRequest:VaultCardRequest ) -> Void
    
    
    ///
    /// Request to print some text on the default printer.
    ///
    @available(*, deprecated: 1.4.0, message: "use print(_ request:PrintRequest) instead")
    func  printText ( _ lines:[String] ) -> Void
    
    ///
    /// Request to print an image on the default printer.
    ///
    /// The size of the image should be limited, and the optimal
    /// width of the image is 384 pixels.
    ///
    /// The img parameter type is implementation specific to the
    /// adapter.
    ///
    ///
    // remove so there isn't a dependency on UIKit and it will work on MacOS
    @available(*, deprecated: 1.4.0, message: "use print(_ request:PrintRequest) instead")
    func  printImage ( _ image:ImageClass ) -> Void
    
    ///
    /// Request to print an image based on a url
    ///
    @available(*, deprecated: 1.4.0, message: "use print(_ request:PrintRequest) instead")
    func printImageFromURL(_ url:String) -> Void
    
    /// Request to print
    ///
    /// - Parameter request: PrintRequest object that contains the information and content needed to print
    func print(_ request:PrintRequest) -> Void
    
    /// Request to retreive available printers
    ///
    /// - Parameter request: RetrievePrintersRequest object that contains additional information to be applied during the request
    func retrievePrinters(_ request:RetrievePrintersRequest) -> Void
    
    /// Request the status of a given print job
    ///
    /// - Parameter request: PrintJobStatusRequest object defining the print job to be queried
    func retrievePrintJobStatus(_ request:PrintJobStatusRequest) -> Void
    
    /// Request that the cash drawer connected to the device be opened.
    ///
    /// - Parameter request: OpenCashDrawerRequest object defining the reason the cash drawer is being opened, and an optional device identifier
    func  openCashDrawer(_ request: OpenCashDrawerRequest) -> Void
    
    ///
    /// Request that the cash drawer connected to the device be opened. Deprecated
    ///
    @available(*, deprecated: 1.4.0, message: "use openCashDrawer(_ request: OpenCashDrawerRequest) instead")
    func  openCashDrawer (reason: String) -> Void
    
    ///
    /// Request to place a message on the device screen.
    ///
    func  showMessage ( _ message:String ) -> Void
    
    
    ///
    /// Request to display the default welcome screen on the device.
    ///
    func  showWelcomeScreen () -> Void
    
    
    ///
    /// Request to display the default thank you screen on the device.
    ///
    func  showThankYouScreen () -> Void
    
    
    ///
    /// Request to display an order on the device.
    ///
    func  showDisplayOrder ( _ order:DisplayOrder ) -> Void
    
    
    ///
    /// Request to display an order on the device.
    ///
    func  removeDisplayOrder ( _ order:DisplayOrder ) -> Void
    
    ///
    /// sends a reset request to the device if the POS and device get out of sync.
    ///
    func  resetDevice ( ) -> Void
    
    ///
    ///
    ///
    func invokeInputOption( _ inputOption:InputOption ) -> Void
    
    ///
    /// Used to request card information. Specifically track1 and track2 information
    ///
    func readCardData( _ request:ReadCardDataRequest ) -> Void
    
    ///
    /// If payment confirmation is required during a Sale, this method accepts the payment
    ///
    func acceptPayment( _ payment:CLVModels.Payments.Payment ) -> Void
    
    ///
    /// If payment confirmation is required during a Sale, this method rejects the payment
    ///
    func rejectPayment( _ payment:CLVModels.Payments.Payment, challenge:Challenge ) -> Void
    
    ///
    /// Used to request a list of pending payments that have been taken offline, but
    /// haven't processed yet. will trigger an onRetrievePendingPaymentsResponse callback
    ///
    func retrievePendingPayments() -> Void
    
    /**
     * Disposes the connector and any connections created by the connector.
     */
    func dispose() -> Void
    
    ///
    /// start an custom activity on the device
    ///
    func startCustomActivity(_ request:CustomActivityRequest) -> Void
    
    ///
    /// send a message to a currently running custom activity
    ///
    func sendMessageToActivity(_ request:MessageToActivity) -> Void
    
    ///
    /// request the current status of the device
    ///
    func retrieveDeviceStatus(_ _request: RetrieveDeviceStatusRequest) -> Void
    
    ///
    /// request the payment for a given external id
    ///
    func retrievePayment(_ _request: RetrievePaymentRequest) -> Void
}
