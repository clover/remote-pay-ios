
Pod::Spec.new do |s|
  s.name             = 'CloverConnector'
  s.version          = '3.0.2'
  s.summary          = 'Provides an api for communicating with a Clover Mini as a customer facing payment device.'

  s.description      = <<-DESC
CloverConnector provides an interface to communicate with a tethered Clover device to enable integration with Clover's customer facing payment device capabilities.

ICloverConnector
- *addCloverConnectorListener* - adds a Clover Connector listener
- *removeCloverConnectorListener* - removes a Clover Connector listener
- *initializeConnection* - initializes the connection and starts communication with the Clover device
- *sale* - method to collect a final sale payment
- *auth* - method to collect a payment that can be tip adjusted
- *preAuth* - method to collect a payment that will not be eligible to be final until a capturePreAuth is processed on this payment
- *capturePreAuth* - method to make a preAuth payment eligible to be tip adjusted or finalized
- *tipAdjustAuth* - method to adjust the tip amount on a payment collected from an auth, or a payment that has been captured via capturePreAuth
- *voidPayment* - queues a request to void a payment
- *refundPayment* - refund a payment or partially refund a final payment
- *voidPaymentRefund* - void a payment refund (Canada flows only)
- *manualRefund* - provide a manual refund a.k.a. naked credit
- *closeout* - posts a closeout request to the server to closeout open payments
- *displayPaymentReceiptOptions* - (Deprecated) display the receipt selection screen
- *displayReceiptOptions* - Display the receipt selection screen for a payment, credit, or refund
- *acceptSignature* - method to accept a signature when the Clover device sends a `verifySignatureRequest`
- *rejectSignature* - method to reject a signature when the Clover device sends a `verifySignatureRequest`
- *vaultCard* - reads a card and retrieves a multi-pay token
- *print* - print the contents of the passed-in `PrintRequest` object
- *retrievePrinters* - request to retreive available printers
- *retrievePrintJobStatus* - request the status of a given print job
- *openCashDrawer* - opens a cash drawer attached to the Clover device with a passed in `OpenCashDrawerRequest` object
- *showMessage* - displays a simple message on the Clover device
- *sendDebugLog* - sends a message to the Clover device to upload its debug logs to the Clover servers
- *showWelcomeScreen* - displays the welcome screen on the Clover device
- *showThankYouScreen* - displays the thank you screen on the Clover device
- *showDisplayOrder* - displays the DisplayOrder passed in on the Clover device
- *removeDisplayOrder* - clears the DisplayOrder from the DisplayOrder screen
- *resetDevice* - requests the device exit whatever activity has been started and returns the device to Welcome. Note: Any payment in process will be voided
- *invokeInputOption* - sends an input option to the device, which may act on behalf of the customer. Input options are passed to the POS via the onDeviceActivityStart callback
- *readCardData* - reads a card and calls back with the card data. Financial cards will be returned encrypted
- *acceptPayment* - method to accept a payment when the Clover device sends a `confirmPaymentRequest`
- *rejectPayment* - method to reject a payment when the Clover device sends a `confirmPaymentRequest`
- *retrievePendingPayments* - requests the device send any payments taken offline that haven't been processed by the server
- *dispose* - cleans up the CloverConnector and disconnects from the Clover device
- *startCustomActivity* - send a request to start a custom activity on the Clover device
- *sendMessageToActivity* - send a message to a custom activity running on the Clover device
- *retrieveDeviceStatus* - query the status of the device, callback on onRetrieveDeviceStatus
- *retrievePayment* - query the device for the status of a payment on the device by its external id, callback on on
- *registerForCustomerProvidedData* - registers for callbacks for customer provided data via the Loyalty API
- *setCustomerInfo* - provides customer data back to the Cover device.  Loyalty API

ICloverConnectorListener
- *onSaleResponse* - called at the completion of a sale request with either a payment or a cancel state
- *onAuthResponse* - called at the completion of an auth request with either a payment or a cancel state
- *onPreAuthResponse* - called at the completion of a preAuth request with either a payment or a cancel state
- *onTipAdjustAuthResponse* - called at the completion ofo a tipAdjustAuth request
- *onVoidPaymentResponse* - called at the completion of a void payment request
- *onRefundPaymentResponse* - called at the completion of a refund payment request
- *onVoidPaymentRefundResponse* - called at the completion of a voidPaymentRefund request
- *onManualRefundResponse* - called at the completion of a manual refund request
- *onCloseoutResponse* - called at the completion of a closeout request
- *onVerifySignatureRequest* - called if the Clover device needs acceptance of a signature
- *onVaultCardResponse* - called in response to a vaultCard request
- *onDeviceActivityStart* - called when the Clover device transitions to a new screen or activity.
- *onDeviceActivityEnd* - called when the Clover device transitions awa from a screen or activity.
- *onDeviceError* - called when an error occurs while trying to send messages to the Clover device
- *onDeviceConnected* - called when the Clover device is initially connected, but not ready to communicate
- *onDeviceReady* - called when the Clover device is ready to communicate and respond to requests
- *onDeviceDisconnected* - called when the Clover device is disconnected from the CloverConnector or not responding
- *onConfirmPaymentRequest* - called if the Clover device needs confirmation of a payment (duplicate verification, offline verification)
- *onTipAdded* - called when a customer selects a tip amount on the Clover device's screen
- *onPrintManualRefundReceipt* - called when a user requests a paper receipt for a Manual Refund
- *onPrintManualRefundDeclineReceipt* - called when a user requests a paper receipt for a declined Manual Refund
- *onPrintPaymentReceipt* - called when a user requests a paper receipt for a Payment
- *onPrintPaymentDeclineReceipt* - called when a user requests a paper receipt for a declined Payment
- *onPrintPaymentMerchantCopyReceipt* - called when a user requests a merchant copy of a Payment receipt
- *onPrintRefundPaymentReceipt* - called when a user requests a paper receipt for a Payment Refund
- *onDisplayReceiptOptionsResponse* - called in response to a DisplayReceiptOptions request
- *onRetrievePrintersResponse* - called at the completion of a retrievePrinters request
- *onPrintJobStatusResponse* - called at the completion of a retrievePrintJobStatus
- *onRetrievePendingPaymentsResponse* - called in response to a retrieve pending payments request. Returns a list of payments not yet submitted to the server
- *onReadCardDataResponse* - called at the completion of a read card data request. Data may come back encrypted depending on the card type and bin
- *onCustomActivityResponse* - called at the completion of a custom activity
- *onResetDeviceResponse* - called at the completion of a resetDevice request
- *onCustomerProvidedDataEvent* - called in response to customer provided data via the Loyalty API.  Call registerForCustomerProvided data to request that this message be sent.
- *onMessageFromActivity* - called if the custom activity wants to send a message back to the POS, prior to finishing
- *onRetrievePaymentResponse* - called at the completion of a retrievePayment request
- *onRetrieveDeviceStatusResponse* - called at the completion of a retrieveDeviceStatus request


DESC

  s.homepage         = 'https://docs.clover.com/build/integration-overview-requirements/'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }
  s.author           = { 'Clover' => 'semi-integrations@clover.com' }
  s.source           = { :git => 'https://github.com/clover/remote-pay-ios.git', :tag => s.version.to_s }

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
# s.watchos.deployment_target = '2.0'

  s.source_files = 'CloverConnector/Classes/**/*.swift'
  

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation'
  s.dependency 'ObjectMapper', '3.3.0'
  s.dependency 'Starscream', '3.0.5'
  s.dependency 'SwiftyJSON', '4.1.0'
end
