//
//  VaultCardResponseMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class VaultCardResponseMessage : Message {
    public var card:CLVModels.Payments.VaultedCard?
    public var status:ResultStatus?
    public var reason:String?
    
    public required init?(map:Map) {
        super.init(method: Method.VAULT_CARD_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        card <- (map["card"], Message.vaultedCardTransform)
        status <- map["status"]
        reason <- map["reason"]
    }
}
