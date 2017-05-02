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
  platform :ios, '8.0'
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
---
