//
//  RegisterForCustomerProvidedDataMessage.swift
//  CloverSDKRemotepay
//
//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class RegisterForCustomerProvidedDataMessage : Message {
    public var configurations:[CLVModels.Loyalty.LoyaltyDataConfig]
    
    init(configurations:[CLVModels.Loyalty.LoyaltyDataConfig]) {
        self.configurations = configurations
        super.init(method: Method.REGISTER_FOR_CUST_DATA)
    }
    
    public required init?(map:Map) {
        self.configurations = [CLVModels.Loyalty.LoyaltyDataConfig]()
        super.init(method: Method.REGISTER_FOR_CUST_DATA)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        configurations <- map["configurations"]
    }
}
