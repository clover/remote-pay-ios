# remote-pay-ios

A swift 2.3 implementation of the CloverConnector to enable iOS and MacOS to communicate with a tethered Clover Mini

## Version 1.3.1
- RC1 -> RC2
  - additional onDeviceError callback for connection errors
  - Fixed a few memory leaks with respect to WebSocket connections and Swift String interpolation
- What's new since 1.2
  - Device status queries to determine that state of the device and payments processed by the device
    - retrievePayment/onRetrievePaymentResponse - query and receive the status of a payment on the device by its external id
    - retrieveDeviceStatus/onRetrieveDeviceStatusResponse - query and receive the status of the device
    - resetDevice now calls back to onResetDeviceResponse with the current status
  - Custom activity support for the Mini
    - startCustomActivity/onCustomActivityResponse - start a custom activity on the Clover device and receive a callback when it is done
    - sendMessageToActivity/onMessageFromActivity - send and receive messages to a custom activity running on the Clover device


## Version 1.2

- Dependencies
  - ObjectMapper - provides JSON serialization/deserialization
  - SwiftyJSON - provides simple JSON parsing
  - Starscream - provides websocket client capabilities

- Building the example app
  - download and install xcode 8.2.1 or 7.3.1 (swift 2.3 support)
  - install cocoapods
    - run `sudo gem install cocoapods`
  - clone/download the CloverConnector repo
  - cd remote-pay-ios/Example
  - run `pod install`
    - should create a Pods directory populated with dependencies
    - should create a workspace file that includes the project, plus a pods project
  - open the CloverConnector.xcworkspace file
    - change the Bundle identifier for the CloverConnector > CloverConnector_Example target
    - change the signing Team for the CloverConnector > CloverConnector_Example target

- Using CloverConnector in your project
  - pod 'CloverConnector', :git => 'https://github.com/clover/remote-pay-ios.git', :tag => '1.3.1-RC2'
  - Example cocoapod (http://cocoapods.org/) `Podfile` snippet
---
  ```platform :ios, '8.0'
  use frameworks!

  target 'Register_App' do
    pod 'CloverConnector', :git => 'https://github.com/clover/remote-pay-ios.git', :tag => '1.3.1-RC2'
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
  end
  ```
---
  Sample code using CloverConnector
  ```swift
import CloverConnector

class ConnectionManager : DefaultCloverConnectorListener, PairingDeviceConfiguration {
    var cc:ICloverConnector?

    func connect() {
        // load from previous pairing, or nil will force/require
        // a new pairing with the device
        let savedAuthToken = loadAuthToken()

        let config = WebSocketDeviceConfiguration(endpoint: "wss://192.168.1.115:12345/remote_pay", remoteApplicationID: "com.yourcompany.pos.app:4.3.5", posName: "RegisterApp", posSerial: "ABC-123", pairingAuthToken: savedAuthToken, pairingDeviceConfiguration: self)

        cc = CloverConnector(config: config)

        cc?.addCloverConnectorListener(self)

        cc?.initializeConnection()
    }

    func doSale() {
        // if onDeviceReady has been called
        let saleRequest = SaleRequest(amount: 1743, externalId: "bc54de43f3")
        // configure other properties of SaleRequest
        cc?.sale(saleRequest)
    }

    // store the token to be loaded later by loadAuthToken
    func saveAuthToken(token:String) {}
    func loadAuthToken() -> String? { return nil }


    // PairingDeviceConfiguration
    func onPairingCode(pairingCode: String) {
        // display pairingCode to user, to be entered on the Clover Mini
    }
    func onPairingSuccess(authToken: String) {
        // pairing is successful
        // save this authToken to pass in to the config for future connections
        // so pairing will happen automatically
        saveAuthToken(authToken)
    }
    // PairingDeviceConfiguration


    // DefaultCloverConnectorListener

    // called when device is disconnected
    override func onDeviceDisconnected() {}
    // called when device is connected, but not ready for requests
    override func onDeviceConnected() {}
    // called when device is ready to take requests. Note: May be called more than once
    override func onDeviceReady(info:MerchantInfo){}
    // required if Mini wants the POS to verify a signature
    override func onVerifySignatureRequest(signatureVerifyRequest: VerifySignatureRequest) {
        //present signature to user, then
        // acceptSignature(...) or rejectSignature(...)
    }
    // required if Mini wants the POS to verify a payment
    override func onConfirmPaymentRequest(request: ConfirmPaymentRequest) {
        //present 1 or more challenges to user, then
        cc?.acceptPayment(request.payment!)
        // or
        // cc?.rejectPayment(...)
    }
    // override other callback methods
    override func onSaleResponse(response:SaleResponse) {
        if response.success {
            // sale successful and payment is in the response (response.payment)
        } else {
            // sale failed or was canceled
        }
    }
    override func onAuthResponse(response:AuthResponse) {}
    override func onPreAuthResponse(response:PreAuthResponse) {}
    // will provide UI information about the activity on the Mini,
    // and may provide input options for the POS to select some
    // options on behalf of the customer
    override func onDeviceActivityStart(deviceEvent:CloverDeviceEvent){} // see CloverConnectorListener.swift for example
                                                                         // of calling invokeInputOption from this callback
    override func onDeviceActivityEnd(deviceEvent:CloverDeviceEvent){}
    // etc.
}

```
