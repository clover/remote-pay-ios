//
//  TestWebSocketDeviceConfiguration.swift
//  CloverConnector
//
//  Copyright © 2017 Clover Networks, Inc. All rights reserved.
//

import XCTest
@testable import CloverConnector

class TestWebSocketDeviceConfiguration: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /// This test checks for 2 things
    /// 1) That the Example App Version matches the Framework Version
    /// 2) That the WebSocketDeviceConfiguration.remoteSDKVersion is set properly based on the Framework Version
    func testRemoteSourceSDK() {
        guard let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String else { XCTFail("Failed to get Test Application Version Number"); return }
        let remoteSourceSDK = "com.cloverconnector.ios.ws:\(appVersion)"
        
        class PDC:PairingDeviceConfiguration {
            @objc func onPairingCode(pairingCode: String) { }
            @objc func onPairingSuccess(authToken: String) { }
        }
        let webSocketDeviceConfiguration = WebSocketDeviceConfiguration(endpoint: "192.168.1.1", remoteApplicationID: "TEST", posName: "TEST", posSerial: "TEST", pairingAuthToken: nil, pairingDeviceConfiguration: PDC())
        
        XCTAssert(remoteSourceSDK == webSocketDeviceConfiguration.remoteSourceSDK, "appVersion: " + appVersion + ", remoteSourceSDK: " + webSocketDeviceConfiguration.remoteSourceSDK)
    }
}
