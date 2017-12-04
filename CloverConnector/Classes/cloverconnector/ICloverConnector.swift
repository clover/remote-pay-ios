import Foundation

///
///  The CloverConnector API serves as the interface for connecting to a Clover device. 
///
///  This document defines the available methods.
///
///
public protocol ICloverConnector : AnyObject {
    
    var CARD_ENTRY_METHOD_MAG_STRIPE:Int { get }
    var CARD_ENTRY_METHOD_ICC_CONTACT:Int { get }
    var CARD_ENTRY_METHOD_NFC_CONTACTLESS:Int { get }
    var CARD_ENTRY_METHOD_MANUAL:Int { get }
    
    var CARD_ENTRY_METHODS_DEFAULT:Int { get }
    
    var MAX_PAYLOAD_SIZE:Int { get }

    
    /// Adds a Clover Connector listener.
    ///
    /// - Parameter cloverConnectorListener: The connection listener.
    func addCloverConnectorListener(_ cloverConnectorListener:ICloverConnectorListener) -> Void
    
    /// Removes a Clover Connector listener.
    ///
    /// - Parameter cloverConnectorListener: The connection listener.
    func removeCloverConnectorListener(_ cloverConnectorListener:ICloverConnectorListener) -> Void
    
    /// Initializes the connection and starts communication with the Clover device.
    /// This method is called after the connector has been created and listeners have been 
    /// added to it.
    /// It must be called before any other method (other than those that add or remove 
    /// listeners).
    func initializeConnection() -> Void

    /// Requests a Sale transaction (purchase).
    ///
    /// - Parameter saleRequest: A SaleRequest object containing basic information for the 
    /// transaction.
    func  sale ( _ saleRequest:SaleRequest ) -> Void

    /// Requests an Auth transaction. The tip for an Auth can be adjusted through the
    /// TipAdjustAuth() call until the batch Closeout is processed.
    /// **Note:** The MerchantInfo.SupportsAuths boolean must be set to true.
    /// - Parameter authRequest: The request details.
    func  auth ( _ authRequest:AuthRequest ) -> Void

    /// Initiates a PreAuth transaction (a pre-authorization for a certain amount). This 
    /// transaction lets the merchant know whether the account associated with a card has 
    /// sufficient funds, without actually charging the card. When the merchant is ready 
    /// to charge a final amount, the POS will call CapturePreAuth() to complete the 
    /// Payment.
    /// **Note:** The MerchantInfo.SupportsPreAuths boolean must be set to true.
    /// - Parameter preAuthRequest: The request details.
    func  preAuth ( _ preAuthRequest:PreAuthRequest ) -> Void

    /// Marks a PreAuth Payment for capture by a Closeout process. After a PreAuth is 
    /// captured, it is effectively the same as an Auth Payment. **Note:** Should only be 
    /// called if the request's PaymentID is from a PreAuthResponse.
    /// - Parameter capturePreAuthRequest: The request details.
    func  capturePreAuth ( _ capturePreAuthRequest:CapturePreAuthRequest ) -> Void

    /// Adjusts the tip for a previous Auth transaction. This call can be made until
    /// the Auth Payment has been finalized by a Closeout.
    /// **Note:** Should only be called if the request's PaymentID is from an 
    /// AuthResponse.
    /// - Parameter authTipAdjustRequest: The request details.
    func  tipAdjustAuth ( _ authTipAdjustRequest:TipAdjustAuthRequest ) -> Void

    /// Voids a transaction.
    ///
    /// - Parameter voidPaymentRequest: A VoidRequest object containing basic information
    /// needed to void the transaction.
    func  voidPayment ( _ voidPaymentRequest:VoidPaymentRequest ) -> Void

    /// Refunds the full or partial amount of a Payment.
    ///
    /// - Parameter refundPaymentRequest: The request details.
    func  refundPayment ( _ refundPaymentRequest:RefundPaymentRequest ) -> Void

    /// Initiates a Manual Refund transaction (a “Refund” or credit
    /// that is not associated with a previous Payment).
    /// - Parameter manualRefundRequest: A ManualRefundRequest object with the request 
    /// details.
    func  manualRefund ( _ manualRefundRequest:ManualRefundRequest ) -> Void
    
    ///
    /// Sends a "cancel" button press to the Clover device. Deprecated.
    /// Use resetDevice() or invokeInputOption() with the screen appropriate options 
    /// instead.
    @available(*, deprecated)
    func  cancel () -> Void

    ///
    /// Sends a request to the Clover server to close out all transactions.
    /// **Note:** The merchant account must be configured to allow transaction closeout.
    ///
    /// - Parameter closeoutRequest: The request details.
    func  closeout ( _ closeoutRequest:CloseoutRequest ) -> Void

    /// Displays the customer-facing receipt options (print, email, etc.) for a Payment on 
    /// the Clover device.
    ///
    /// - Parameters:
    ///   - orderId: The ID of the Order associated with the receipt.
    ///   - paymentId: The ID of the Payment associated with the receipt.
    func  displayPaymentReceiptOptions(orderId:String, paymentId: String) -> Void

    /// If a signature is captured during a transaction, this method accepts the signature
    /// as entered.
    /// - Parameter signatureVerifyRequest: The accepted VerifySignatureRequest the device
    /// passed to onVerifySignatureRequest().
    func  acceptSignature ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void
      
    /// If a signature is captured during a transaction, this method rejects the signature
    /// as entered.
    /// - Parameter signatureVerifyRequest: The rejected VerifySignatureRequest()
    /// the device passed to onVerifySignatureRequest().
    func  rejectSignature ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void

    /// Asks the Clover device to capture card information and request a payment token
    /// from the payment gateway. The payment token can be used for future Sale and Auth 
    /// requests in place of the card details. The merchant account must be configured to 
    /// allow payment tokens.
    /// **Note:** The MerchantInfo.SupportsVaultCards boolean must be set to true.
    ///
    /// - Parameter vaultCardRequest: The request details, including the card entry 
    /// methods allowed to capture the payment token. If the card entry methods are null, 
    /// the default values (CARD_ENTRY_METHOD_MAG_STRIPE, CARD_ENTRY_METHOD_ICC_CONTACT, 
    /// and CARD_ENTRY_METHOD_NFC_CONTACTLESS) will be used.
    func  vaultCard ( _ vaultCardRequest:VaultCardRequest ) -> Void
    
    ///
    /// Prints custom messages in plain text through the Clover Mini's built-in printer.
    /// Deprecated.
    @available(*, deprecated: 1.4.0, message: "use print(_ request:PrintRequest) instead")
    func  printText ( _ lines:[String] ) -> Void
    
    /// Prints an image on paper receipts through the Clover Mini's built-in printer.
    /// Deprecated.
    @available(*, deprecated: 1.4.0, message: "use print(_ request:PrintRequest) instead")
    func  printImage ( _ image:ImageClass ) -> Void
    
    /// Prints an image from the web on paper receipts through the Clover device's 
    /// built-in printer. Deprecated.
    /// - Parameter url: The URL for the image to print.
    @available(*, deprecated: 1.4.0, message: "use print(_ request:PrintRequest) instead")
    func printImageFromURL(_ url:String) -> Void
    
    /// Sends a print request using the PrintRequest object. 
    /// Used to print text, images, and images from a URL using the specified printer.
    ///
    /// - Parameter request: The PrintRequest details.
    func print(_ request:PrintRequest) -> Void

    /// Queries available printers attached to the Clover device.
    ///
    /// - Parameter request: The RetrievePrintersRequest details.
    func retrievePrinters(_ request:RetrievePrintersRequest) -> Void
    
    /// Queries the status of a print job.
    ///
    /// - Parameter request: A PrintJobStatusRequest object containing the request
    /// details.
    func retrievePrintJobStatus(_ request:PrintJobStatusRequest) -> Void
    
    /// Opens the first cash drawer found connected to the Clover device.
    /// The reason for opening the cash drawer must be set on OpenCashDrawerRequest.
    ///
    /// - Parameter request: The request object defining the reason
    /// the cash drawer is being opened, and an optional device identifier.
    func  openCashDrawer(_ request: OpenCashDrawerRequest) -> Void
    
    ///
    /// Opens the cash drawer connected to the Clover device. Deprecated.
    ///
    /// @available(*, deprecated: 1.4.0, message: "use openCashDrawer(_ request: 
    /// OpenCashDrawerRequest) instead")
    func  openCashDrawer (reason: String) -> Void
    
    /// Displays a string-based message on the Clover device's screen.
    ///
    /// - Parameter message: The string message to display.
    func  showMessage ( _ message:String ) -> Void
    
    ///
    /// Displays the welcome screen on the Clover device.
    ///
    func  showWelcomeScreen () -> Void
    
    ///
    /// Displays the thank you screen on the Clover device.
    ///
    func  showThankYouScreen () -> Void   
    
    /// Displays an Order and associated lineItems on the Clover device. Will replace an 
    /// Order that is already displayed on the device screen.
    /// - Parameter order: The Order to display.
    func  showDisplayOrder ( _ order:DisplayOrder ) -> Void  
    
    /// Removes the DisplayOrder object from the Clover device's screen.
    /// 
    /// - Parameter order: The Order to remove.
    func  removeDisplayOrder ( _ order:DisplayOrder ) -> Void
    
    /// Sends a request to reset the Clover device back to the welcome screen. Can be used 
    /// when the device is in an unknown or invalid state from the perspective of the POS.
    /// **Note:** This request could cause the POS to miss a transaction or other 
    /// information. Use cautiously as a last resort.
    func  resetDevice ( ) -> Void
    
    /// Sends a keystroke to the Clover device that invokes an input option (OK, 
    /// CANCEL, DONE, etc.) on the customer's behalf.
    /// InputOptions are on the CloverDeviceEvent passed to onDeviceActivityStart().
    /// - Parameter inputOption: The input option to invoke.
    func invokeInputOption( _ inputOption:InputOption ) -> Void
    
    /// Requests card information (specifically Track 1 and Track 2 card data).
    ///
    /// - Parameter request: The ReadCardDataRequest details.
    func readCardData( _ request:ReadCardDataRequest ) -> Void
    
    /// If Payment confirmation is required during a transaction due to a Challenge,
    ///  this method accepts the Payment. A Challenge may be triggered
    ///  by a potential duplicate Payment or an offline Payment.
    /// - Parameter payment: The Payment to accept.
    func acceptPayment( _ payment:CLVModels.Payments.Payment ) -> Void
    
    /// If Payment confirmation is required during a transaction due to a Challenge,
    ///  this method rejects the Payment. A Challenge may be triggered
    ///  by a potential duplicate Payment or an offline Payment.
    /// - Parameter payment: The Payment to reject.
    /// - Parameter challenge: The Challenge that resulted in Payment rejection.
    func rejectPayment( _ payment:CLVModels.Payments.Payment, challenge:Challenge ) -> Void
    
    ///
    /// Retrieves a list of unprocessed Payments that were taken offline
    ///  and are pending submission to the server.
    ///
    func retrievePendingPayments() -> Void
    
    /// Disposes the connection to the Clover device. After this is called, the
    /// connection to the device is severed, and the CloverConnector object is
    /// no longer usable. Instantiate a new
    /// CloverConnector object in order to call initializeConnection().
    func dispose() -> Void
    
    /// Starts a Custom Activity on the Clover device.
    ///
    /// - Parameter request: The CustomActivityRequest details.
    func startCustomActivity(_ request:CustomActivityRequest) -> Void
    
    /// Sends a message to a Custom Activity running on a Clover device.
    ///
    /// - Parameter request: The MessageToActivity request with the message
    /// to send to the Custom Activity.
    func sendMessageToActivity(_ request:MessageToActivity) -> Void
    
    /// Sends a message requesting the current status of the Clover device.
    ///
    /// - Parameter request: The RetrieveDeviceStatusRequest details.
    func retrieveDeviceStatus(_ _request: RetrieveDeviceStatusRequest) -> Void
    
    /// Requests the Payment information corresponding to the externalPaymentId passed 
    /// in. Only valid for Payments made in the past 24 hours on the Clover device 
    /// queried.
    /// - Parameter request: The RetrievePaymentRequest details.
    func retrievePayment(_ _request: RetrievePaymentRequest) -> Void
}
