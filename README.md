![Clover logo](https://www.clover.com/assets/images/public-site/press/clover_primary_gray_rgb.png)

# Clover SDK for iOS Integration

A Swift implementation of the CloverConnector to enable iOS and MacOS to communicate with a tethered Clover Mini or Flex.

## Version

Current version: 3.0.0

NOTE: Full support for version 3.0.0 of the SDK requires version 208 or higher of the Pay Display app.

### Dependencies
- ObjectMapper - Provides JSON serialization and deserialization.
- SwiftyJSON - Provides simple JSON parsing.
- Starscream - provides websocket client capabilities. NOTE: we have forked this and made some small tweaks that improve large-file handling, so be sure to point to our fork (example below).

## Example Implementation

This SDK is provided with an example implementation available at [https://github.com/clover/remote-pay-ios-examples](https://github.com/clover/remote-pay-ios-examples)

## Using CloverConnector in your project
* Update your Podspec to include the queuePriority branch of Starscream, 3.0.0 branch of CloverConnector, and the Swift 4.2 post_install script
    * pod 'Starscream', :git => 'https://github.com/clover/Starscream.git', :branch => 'queuePriority-2.0.0'
    * pod 'CloverConnector', :git => 'https://github.com/clover/remote-pay-ios.git', :tag => '3.0.0'
* Add the post_install script (see example) to set the Swift version of the pods to 4.2
    * Example cocoapod (http://cocoapods.org/) `Podfile` snippet
---
```ruby
platform :ios, '9.0'

use_frameworks!

target 'RegisterApp' do

    # The queuePriority branch of our fork of the Starscream framework is required for reliable transport of large files
    # Defining it here in the PodFile overrides the podspec dependency, which isn't allowed to specify a specific location and branch
    pod 'Starscream', :git => 'https://github.com/clover/Starscream.git', :branch => 'queuePriority-2.0.0'

    pod 'CloverConnector', :git => 'https://github.com/clover/remote-pay-ios.git', :tag => '3.0.0'

    post_install do |installer|
        ['CloverConnector'].each do |targetName|
            targets = installer.pods_project.targets.select { |target| target.name == targetName }
            target = targets[0]
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.2'
            end
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

        let config = WebSocketDeviceConfiguration(endpoint: "wss://192.168.1.115:12345/remote_pay",
            remoteApplicationID: "com.yourcompany.pos.app:4.3.5",
            posName: "RegisterApp", posSerial: "ABC-123",
            pairingAuthToken: savedAuthToken, pairingDeviceConfiguration: self)

        cc = CloverConnectorFactory.createICloverConnector(config)
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
    override func onDeviceActivityStart(deviceEvent:CloverDeviceEvent){} // see CloverConnectorListener.swift for example of calling invokeInputOption from this callback
    override func onDeviceActivityEnd(deviceEvent:CloverDeviceEvent){}
    // etc.
}

```

## Additional Resources

* [Release Notes](https://github.com/clover/remote-pay-ios/releases)
* [Example Implementation](https://github.com/clover/remote-pay-ios-examples)
* [Tutorial for the iOS SDK](https://docs.clover.com/build/getting-started-with-clover-connector/?sdk=ios)
* [API Documentation](https://clover.github.io/remote-pay-ios/3.0.0/docs/index.html)
* [Clover Developer Community](https://community.clover.com/index.html)

## License 
Copyright © 2018 Clover Network, Inc. All rights reserved.
