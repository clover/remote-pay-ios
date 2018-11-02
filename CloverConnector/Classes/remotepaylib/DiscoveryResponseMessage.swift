//
//  DiscoveryResponseMessage.swift
//  CloverSDKRemotepay
//
//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper




/*
 The message sent to the clover device upon connection
 */
public class DiscoveryResponseMessage:Message {
    
    /*
     * Identifier for the request
     */
    var requestId:String? = nil
    var merchantId:String? = nil
    var merchantMId:String? = nil
    var merchantName:String? = nil
    var model:String? = nil
    var name:String? = nil
    var serial:String? = nil
    var ready:Bool? = nil
    var supportsAuth:Bool? = nil
    var supportsPreAuth:Bool? = nil
    var supportsVaultCard:Bool? = nil
    var supportsManualRefund:Bool? = nil
    var supportsMultiPayToken:Bool? = nil
    var supportsTipAdjust:Bool? = nil
    var supportsAcknowledgement:Bool? = nil
    var supportsVoidPaymentResponse:Bool? = nil
    
    public required init() {
        super.init(method: .DISCOVERY_RESPONSE)
    }
    
    required public init?(map:Map) {
        super.init(method: .DISCOVERY_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        requestId <- map["requestId"]
        merchantId <- map["merchantId"]
        merchantMId <- map["merchandMId"]
        merchantName <- map["merchantName"]
        model <- map["model"]
        name <- map["name"]
        serial <- map["serial"]
        ready <- map["ready"]
        supportsAuth <- map["supportsAuth"]
        supportsPreAuth <- map["supportsPreAuth"]
        supportsVaultCard <- map["supportsVaultCard"]
        supportsManualRefund <- map["supportsManualRefund"]
        supportsMultiPayToken <- map["supportsMultiPayToken"]
        supportsTipAdjust <- map["supportsTipAdjust"]
        supportsAcknowledgement <- map["supportsAcknowledgement"]
        supportsVoidPaymentResponse <- map["supportsVoidPaymentResponse"]
    }
    
}

