//
//  MerchantInfo.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDKRemotepay

@objc
public class MerchantInfo : NSObject {
    public private(set) var merchantId:String?
    public private(set) var merchantMId:String?
    public private(set) var merchantName:String?
    
    public var  supportsAuths:Bool = true
    public var  supportsPreAuths:Bool = true
    public var  supportsSales:Bool = true
    public var  supportsVaultCards:Bool = true
    public var  supportsManualRefunds:Bool = true
    public var  supportsVoids:Bool = true
    public var  supportsTipAdjust:Bool = true
    
    
    public private(set) var deviceInfo:DeviceInfo?
    
//    public init(discoveryResponse: )
    
    public override init() {
        self.merchantId = ""
        self.merchantMId = ""
        self.merchantName = ""
        self.deviceInfo = DeviceInfo(name: "", serial: "", model: "")
        super.init()
    }
    
    public init(id:String?, mid:String?, name:String?, deviceName:String?, deviceSerialNumber:String?, deviceModel:String?) {
        self.merchantId = id
        self.merchantMId = mid
        self.merchantName = name
        self.deviceInfo = DeviceInfo(name: deviceName, serial:deviceSerialNumber, model:deviceModel);
        super.init()
    }
}

@objc
public class DeviceInfo : NSObject {
    public private(set) var deviceName:String?
    public private(set) var deviceSerial:String?
    public private(set) var deviceModel:String?
    
    
    public init(name:String?, serial:String?, model:String?) {
        self.deviceName = name
        self.deviceSerial = serial
        self.deviceModel = model
        super.init()
    }
}
