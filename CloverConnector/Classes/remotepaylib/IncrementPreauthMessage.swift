//  
//  IncrementPreauthMessage.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper

public class IncrementPreauthMessage : Message {
    public var amount: Int?
    public var paymentId: String?
    
    public init() {
        super.init(method: .INCREMENT_PREAUTH_REQUEST)
    }
    
    public required init?(map:Map) {
        super.init(method: .INCREMENT_PREAUTH_REQUEST)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        amount <- map["amount"]
        paymentId <- map["paymentId"]
    }
}
