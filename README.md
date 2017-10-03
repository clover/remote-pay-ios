# remote-pay-ios

A Swift 4 implementation of the CloverConnector to enable iOS and MacOS to communicate with a tethered Clover Mini.

## Version 1.4
NOTE: Full support of version 1.4 features requires remote-pay version 138 or higher.

NOTE: To use the Swift 2.3 compatible version of this library, you will need to point your Podfile at the [1.4.0-swift2.3](https://github.com/clover/remote-pay-ios/tree/1.4.0-swift2.3) branch as listed below in the code sample.

- New Print API
    - please migrate all print requests to the new API utilizing the PrintRequest object:
        - `print(request: PrintRequest)`
    - printing via type-specific functions is deprecated and will be removed in a future release:
        - `printText(lines: [String])`
        - `printImage(image: UIImage)`
        - `printImageFromURL(image: String)`
    - New API to open cash drawers
        - please migrate all cash drawer requests to the new API utilizing the OpenCashDrawerRequest object:
            - `openCashDrawer(request: OpenCashDrawerRequest)`
        - opening of cash drawers with a reason string is deprecated and will be removed in a future release:
            - `openCashDrawer(reason: String)`
    - Query available printers
        - `retrievePrinters(request: RetrievePrintersRequest)`
        - `onRetrievePrintersResponse(retrievePrintersResponse: RetrievePrintersResponse)`
    - Query the status of a print job
        - `retrievePrintJobStatus(request: PrintJobStatusRequest)`
        - `onPrintJobStatusResponse(printJobStatusResponse: PrintJobStatusResponse)`
- Added support for large image printing utilizing message fragmenting
- Creation of an instance of the CloverConnector should now go through the `CloverConnectorFactory` (see example below)
- Support MacOS based apps

## Version 1.3.1 (Swift 2.3 only)
- additional onDeviceError callback for connection errors
- Fixed a few memory leaks with respect to WebSocket connections and Swift String interpolation
- Device status queries to determine that state of the device and payments processed by the device
- retrievePayment/onRetrievePaymentResponse - query and receive the status of a payment on the device by its external id
- retrieveDeviceStatus/onRetrieveDeviceStatusResponse - query and receive the status of the device
- resetDevice now calls back to onResetDeviceResponse with the current status
- Custom activity support for the Mini
- startCustomActivity/onCustomActivityResponse - start a custom activity on the Clover device and receive a callback when it is done
- sendMessageToActivity/onMessageFromActivity - send and receive messages to a custom activity running on the Clover device

### Dependencies
- ObjectMapper - provides JSON serialization/deserialization
- SwiftyJSON - provides simple JSON parsing
- Starscream - provides websocket client capabilities. NOTE: we have forked this and made some small tweaks that improve large-file handling, so be sure to point to our fork (example below)

## Building the example app
- download and install Xcode 9
- install cocoapods
- run `sudo gem install cocoapods`
- clone/download the CloverConnector repo
- `cd remote-pay-ios/Example`
- run `pod install`
- should create a Pods directory populated with the Pods specified in the podspec
- should create a workspace file that includes the project, plus a pods project
- run `pod install` a second time
- should update the Pods directory with the installed Pods' dependencies
- open the CloverConnector.xcworkspace file
- change the Bundle identifier for the CloverConnector > CloverConnector_Example target
- change the signing Team for the CloverConnector > CloverConnector_Example target

## Using CloverConnector in your project
- Update your Podspec to include the queuePriority branch of Starscream, 1.4 branch of CloverConnector, and the Swift 4.0 post_install script
- pod 'Starscream', :git => 'https://github.com/clover/Starscream.git', :branch => 'queuePriority'
- pod 'CloverConnector', :git => 'https://github.com/clover/remote-pay-ios.git', :tag => '1.4.0'
- Add the post_install script (see example) to set the Swift version of the pods to 4.0
- Example cocoapod (http://cocoapods.org/) `Podfile` snippet
---
```ruby
platform :ios, '9.0'

use_frameworks!

target 'RegisterApp' do

    # The queuePriority branch of our fork of the Starscream framework is required for reliable transport of large files
    # Defining it here in the PodFile overrides the podspec dependency, which isn't allowed to specify a specific location and branch
    pod 'Starscream', :git => 'https://github.com/clover/Starscream.git', :branch => 'queuePriority'

    pod 'CloverConnector', :git => 'https://github.com/clover/remote-pay-ios.git', :tag => '1.4.0'

    post_install do |installer|
        ['CloverConnector'].each do |targetName|
            targets = installer.pods_project.targets.select { |target| target.name == targetName }
            target = targets[0]
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
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

