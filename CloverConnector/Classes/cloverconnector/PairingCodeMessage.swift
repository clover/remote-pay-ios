//
//  PairingCodeMessage.swift
//  Pods
//
//  
//
//

import Foundation
import ObjectMapper

public class PairingCodeMessage:Mappable {
    var pairingCode:String?
    
    public init(pairingCode:String) {
        self.pairingCode = pairingCode;
    }
    
    public required init?(map:Map) {
        
    }
    
    public func mapping(map:Map) {
        pairingCode <- map["pairingCode"]
    }
    
}
