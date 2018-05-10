
Pod::Spec.new do |s|
  s.name             = 'CloverConnector'
  s.version = '1.4.3'
  s.summary          = 'Provides an api for communicating with a Clover Mini as a customer facing payment device.'

  s.description      = <<-DESC
CloverConnector provides an interface to communicate with a tethered Clover device to enable integration with Clover's customer facing payment device capabilities.

ICloverConnector
- *sale* - method to collect a final sale payment
- *auth* - method to collect a payment that can be tip adjusted
- *preAuth* - method to collect a payment that will not be eligible to be final until a capturePreAuth is processed on this payment
- *tipAdjustAuth* - method to adjust the tip amount on a payment collected from an auth, or a payment that has been captured via capturePreAuth
- *capturePreAuth* - method to make a preAuth payment eligible to be tip adjusted or finalized
- *voidPayment* - queues a request to void a payment
- *refundPayment* - refund a payment or partially refund a final payment
- *manualRefund* - provide a manual refund a.k.a. naked credit
- *cancel* - sends a cancel command to exit activities that support the cancel option
- *closeout* - posts a closeout request to the server to closeout open payments
- *displayPaymentReceiptOptions* - display the receipt selection screen
- *acceptSignature* - method to accept a signature when the Clover device sends a `verifySignatureRequest`
- *rejectSignature* - method to reject a signature when the Clover device sends a `verifySignatureRequest`
- *vaultCard* - reads a card and retrieves a multi-pay token
- *print* - print the contents of the passed-in `PrintRequest` object
- *printText* - prints simple text *deprecated*
- *printImage* - prints the passed in image *deprecated*
- *printImageFromURL* - print an image references in the url *deprecated*
- *retrievePrinters* - request to retreive available printers
- *retrievePrintJobStatus* - request the status of a given print job
- *openCashDrawer* - opens a cash drawer attached to the Clover device with a passed in `OpenCashDrawerRequest` object
- *showMessage* - displays a simple message on the Clover device
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
- *dispose* - cleans up the CloverConnector and disconnects from the Clover Mini
- *retrievePayment* - query the device for the status of a payment on the device by its external id, callback on on
- *retrieveDeviceStatus* - query the status of the device, callback on onRetrieveDeviceStatus
- *startCustomActivity* - send a request to start a custom activity on the Clover device
- *sendMessageToActivity* - send a message to a custom activity running on the Clover device

ICloverConnectorListener
- *onSaleResponse* - called at the completion of a sale request with either a payment or a cancel state
- *onAuthResponse* - called at the completion of an auth request with either a payment or a cancel state
- *onPreAuthResponse* - called at the completion of a preAuth request with either a payment or a cancel state
- *onTipAdjustAuthResponse* - called at the completion ofo a tipAdjustAuth request
- *onCapturePreAuthResponse* - called at the completion of a capturePreAuth request
- *onRefundPaymentResponse* - called at the completion of a refund payment request
- *onManualRefundResponse* - called at the completion of a manual refund request
- *onVoidPaymentResponse* - called at the completion of a void payment request
- *onCloseoutResponse* - called at the completion of a closeout request
- *confirmPaymentRequest* - called if the Clover device needs confirmation of a payment (duplicate verification, offline verification)
- *verifySignatureRequest* - called if the Clover device needs acceptance of a signature
- *onRetrievePendingPaymentsResponse* - called in response to a retrieve pending payments request. Returns a list of payments not yet submitted to the server
- *onReadCardDataResponse* - called at the completion of a read card data request. Data may come back encrypted depending on the card type and bin
- *onCustomActivityResponse* - called at the completion of a custom activity
- *onResetDeviceResponse* - called at the completion of a resetDevice request
- *onMessageFromActivity* - called if the custom activity wants to send a message back to the POS, prior to finishing
- *onRetrievePaymentResponse* - called at the completion of a retrievePayment request
- *onRetrieveDeviceStatusResponse* - called at the completion of a retrieveDeviceStatus request
- *onRetrievePrintersResponse* - called at the completion of a retrievePrinters request
- *onPrintJobStatusResponse* - called at the completion of a retrievePrintJobStatus



DESC

  s.homepage         = 'https://docs.clover.com/build/integration-overview-requirements/'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }
  s.author           = { 'Clover' => 'semi-integrations@clover.com' }
  s.source           = { :git => 'https://github.com/clover/remote-pay-ios.git', :tag => s.version.to_s }

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
# s.watchos.deployment_target = '2.0'

  s.source_files = 'CloverConnector/Classes/**/*.swift'
  

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation'
  s.dependency 'ObjectMapper', '3.0.0'
  s.dependency 'Starscream', '2.1.1'
  s.dependency 'SwiftyJSON', '3.1.4'
end
