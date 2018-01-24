//
//  TestRemoteSourceSDK.swift
//  CloverConnector_Tests
//
//  Copyright © 2017 Clover Networks, Inc. All rights reserved.
//

import XCTest
@testable import CloverConnector

class Test_cloverconnector_WebSocketDeviceConfiguration: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - remoteSourceSDK
    //
    // This test examines the remoteSourceSDK in the WebSocketDeviceConfiguration, and compares it to a separately generated
    // string based on the main version string.  This comparison validates that the remoteSourceSDK is properly extracted
    // from the framework bundle, and tangentially checks that both the framework and the example app have been set to
    // the same value.
    //
    func testRemoteSourceSDK() {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { XCTFail("Failed to get Test Application Version Number"); return }
        let remoteSourceSDK = "com.cloverconnector.ios.ws:\(appVersion)"

        class PDC:PairingDeviceConfiguration {
            func onPairingCode(_ pairingCode: String) { }
            func onPairingSuccess(_ authToken: String) { }
        }
        let webSocketDeviceConfiguration = WebSocketDeviceConfiguration(endpoint: "192.168.1.1", remoteApplicationID: "TEST", posName: "TEST", posSerial: "TEST", pairingAuthToken: nil, pairingDeviceConfiguration: PDC())

        XCTAssert(remoteSourceSDK == webSocketDeviceConfiguration.remoteSourceSDK)
    }
}
