//
//  PairingRequestMessage.swift
//  Pods
//
//  
//
//

import Foundation
import ObjectMapper

public class PairingRequestMessage : Mappable {
    
    public var method:String = PairingCode.PAIRING_REQUEST
    public var id:String?
    public var payload:String?
    public var type:String = "COMMAND"
    
    fileprivate static var reqNumber:Int = 0;
    
    public init( request:PairingRequest ) {
        self.id = "PR-" + String(describing: PairingRequestMessage.reqNumber += 1)
        self.payload = Mapper().toJSONString(request, prettyPrint: true)
    }
    
    public required init?(map:Map) {
        
    }
    
    public func mapping(map:Map) {
        self.id <- map["id"]
        self.payload <- map["payload"]
        self.method <- map["method"]
        self.type <- map["type"]
    }
    
}
