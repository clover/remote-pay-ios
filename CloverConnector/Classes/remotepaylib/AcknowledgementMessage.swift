//
//  AcknowledgementMessage.swift
//  Pods
//
//  
//
//

import Foundation
import ObjectMapper

public class AcknowledgementMessage : Message {
    
    public var sourceMessageId:String?
    
    public required init?(map:Map) {
        super.init(method: .ACK)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        sourceMessageId <- map["sourceMessageId"]
    }
}
