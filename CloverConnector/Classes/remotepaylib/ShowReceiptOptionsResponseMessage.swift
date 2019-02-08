//  
//  ShowReceiptOptionsResponseMessage.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper

public class ShowReceiptOptionsResponseMessage: Message {
    public var status: ResultStatus
    public var reason: String
    
    public init(status: ResultStatus, reason: String) {
        self.status = status
        self.reason = reason
        super.init(method: .SHOW_RECEIPT_OPTIONS_RESPONSE)
    }
    
    public required init?(map: Map) {
        self.status = .FAIL
        self.reason = ""
        super.init(method: .SHOW_RECEIPT_OPTIONS_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        self.status <- map["status"]
        self.reason <- map["reason"]
    }
}
