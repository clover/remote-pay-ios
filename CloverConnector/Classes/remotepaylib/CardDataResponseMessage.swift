//
//  CardDataResponseMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class CardDataResponseMessage: Message {
    public var cardData:CardData?
    public var status:ResultStatus?
    public var reason:String?
    
    public required init?(map:Map) {
        super.init(method: .CARD_DATA_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        cardData <- map["cardData"]
        status <- map["status"]
        reason <- map["reason"]
    }
}
