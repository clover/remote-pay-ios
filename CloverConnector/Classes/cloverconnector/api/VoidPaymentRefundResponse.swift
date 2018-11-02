//  
//  VoidPaymentRefundResponse.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper

public class VoidPaymentRefundResponse: BaseResponse {
    public var refundId: String
    
    public init(success: Bool, result: ResultCode, refundId: String, reason: String?, message: String?) {
        self.refundId = refundId
        super.init(success: success, result: result, reason: reason, message: message)
    }
    
    //The required initializer to conform to <Mappable>. Probably won't ever be used because we'll use one of the other two initialiers
    required public init?(map: Map) {
        refundId = ""
        super.init(success: false, result: ResultCode.ERROR)
    }
}

