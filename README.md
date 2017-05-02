# remote-pay-ios

A swift 2.3 implementation of the CloverConnector to enable iOS and MacOS to communicate with a tethered Clover Mini

- Dependencies
  - ObjectMapper - provides JSON serialization/deserialization
  - SwiftyJSON - provides simple JSON parsing
  - Starscream - provides websocket client capabilities

- Using CloverConnector
  - pod 'CloverConnector', '1.2.0.b'
  - Example cocoapod (http://cocoapods.org/) `Podfile` snippet
---
  ```platform :ios, '8.0'
  use frameworks!

  target 'Register_App' do
    pod 'CloverConnector', '1.2.0.b'
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
  end
  ```
  Some sample code to get started
  ```swift
  import CloverConnector

  class ConnectionManager : DefaultCloverConnectorListener, PairingDeviceConfiguration {
    var cc:ICloverConnector?

    func connect() {
          let config = WebSocketDeviceConfiguration(endpoint: "wss://192.168.1.115:12345/remote_pay", remoteApplicationID: "com.yourcompany.pos.app:4.3.5", posName: "Aisle-13b", posSerial: "ABC-123", pairingAuthToken: nil, pairingDeviceConfiguration: self)
        config.pingFrequency = 5
        cc = CloverConnector(config: config)

        cc?.addCloverConnectorListener(self)

        cc?.initializeConnection()
    }

    // PairingDeviceConfiguration
    func onPairingCode(pairingCode: String) {
        // display pairingCode to user
    }
    func onPairingSuccess(authToken: String) {
        // pairing is successful
    }

    // DefaultCloverConnectorListener
    override func onVerifySignatureRequest(signatureVerifyRequest: VerifySignatureRequest) {
        //present signature to user, then
        // acceptSignature(...) or rejectSignature(...)
    }
    override func onConfirmPaymentRequest(request: ConfirmPaymentRequest) {
        //present challenges to user, then
        // cc?.confirmPayment(...)
        // or
        // cc?.rejectPayment(...)
    }
    // override other callback method
    override onSaleResponse(response:SaleResponse) {}
    // etc.
```
