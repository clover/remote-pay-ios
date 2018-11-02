//
//  CustomerProvidedDataMessage.swift
//  CloverSDKRemotepay
//
//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class CustomerProvidedDataMessage : Message {
    public var result:ResultStatus = .FAIL
    public var eventId:String?
    public var config:CLVModels.Loyalty.LoyaltyDataConfig?
    public var data:String?
    
    init(_ result:ResultStatus, eventId:String?, config:CLVModels.Loyalty.LoyaltyDataConfig?, data:String?) {
        self.result = result
        self.eventId = eventId
        self.config = config
        self.data = data
        super.init(method: .CUSTOMER_PROVIDED_DATA_MESSAGE)
    }
    
    public required init?(map:Map) {
        super.init(method: Method.CUSTOMER_PROVIDED_DATA_MESSAGE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        eventId <- map["eventId"]
        config <- (map["config"], CLVTransforms.Loyalty.loyaltyDataConfig)
        data <- map["data"]
    }
}
