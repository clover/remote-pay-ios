//
//  TestDeviceConfiguration.swift
//  CloverConnector
//
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
@testable import CloverConnector

class TestDeviceConfiguration: NSObject, CloverDeviceConfiguration {
    var remoteApplicationID: String
    
    var remoteSourceSDK: String = "com.cloverconnector.ios.test"
    
    public var maxCharInMessage:Int = 50000
    
    public init(remoteApplicationID:String) {
        self.remoteApplicationID = remoteApplicationID
        super.init()
    }
    
    func getTransport() -> CloverTransport? {
        return TestCloverTransport()
    }
    
    func getCloverDeviceTypeName() -> String {
        return ""
    }
    
    func getMessagePackageName() -> String {
        return "com.clover.remote_protocol_broadcast.app"
    }
    
    func getName() -> String {
        return "Test Transport"
    }
    
    func getMaxMessageCharacters() -> Int {
        return maxCharInMessage
    }
    

}
