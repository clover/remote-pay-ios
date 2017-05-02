//
//  TransactionResponse.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

public class BaseResponse : NSObject, Mappable {
    public var success:Bool
    public var result:ResultCode
    public var reason:String?
    public var message:String?
    
    public override init() {
        result = ResultCode.FAIL
        success = false
        super.init()
    }
    
    public init(success:Bool, result:ResultCode) {
        self.success = success
        self.result = result
        super.init()
    }
    
    public init(success:Bool, result:ResultCode, reason:String?, message:String?) {
        self.success = success
        self.result = result
        self.reason = reason
        super.init()
    }
    
    required public init?(_ map: Map) {
        self.success = false
        self.result = ResultCode.CANCEL
    }
    
    public func mapping(map: Map) {
        success <- map["success"]
        result <- map["result"]
        reason <- map["reason"]
        message <- map["message"]
    }
}
