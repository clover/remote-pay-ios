//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

/**
 Contains merchant information as well as some high level capabilities
 */
public class MerchantInfo : NSObject {
    /// The id of the merchant
    public fileprivate(set) var merchantId:String?
    /// the merchant mid
    public fileprivate(set) var merchantMId:String?
    /// the merchant name
    public fileprivate(set) var merchantName:String?
    
    /// whether the merchant is configured to process auth requests
    public var  supportsAuths:Bool = true
    /// whether the merchant is configured to process preAuth requests
    public var  supportsPreAuths:Bool = true
    /// whether the merchant is configured to process sale requests
    public var  supportsSales:Bool = true
    /// whether the merchant is configured to support vault card
    public var  supportsVaultCards:Bool = true
    /// whether the merchant is configured to support manual refund requests
    public var  supportsManualRefunds:Bool = true
    /// whether the merchant is configured to support void requests
    public var  supportsVoids:Bool = true
    /// whether the merchant is configured to support tip adjusts
    public var  supportsTipAdjust:Bool = true
    
    /// contains information about the tethered device
    public fileprivate(set) var deviceInfo:DeviceInfo?
    
    
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

/**
 Contains information about the connected device
 */
public class DeviceInfo : NSObject {
    public fileprivate(set) var deviceName:String?
    public fileprivate(set) var deviceSerial:String?
    public fileprivate(set) var deviceModel:String?
    
    
    public init(name:String?, serial:String?, model:String?) {
        self.deviceName = name
        self.deviceSerial = serial
        self.deviceModel = model
        super.init()
    }
}
