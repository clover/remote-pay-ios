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
    public var remoteApplicationID:String?
    public var remoteSourceSDK:String?
    
    fileprivate static var reqNumber:Int = 0;
    
    public init( request:PairingRequest ) {
        self.id = "PR-" + String(describing: PairingRequestMessage.reqNumber += 1)
        self.payload = Mapper().toJSONString(request, prettyPrint: true)
        self.remoteApplicationID = request.remoteApplicationID
        self.remoteSourceSDK = request.remoteSourceSDK
    }
    
    public required init?(map:Map) {
        
    }
    
    public func mapping(map:Map) {
        self.id <- map["id"]
        self.payload <- map["payload"]
        self.method <- map["method"]
        self.type <- map["type"]
        self.remoteApplicationID <- map["remoteApplicationID"]
        self.remoteSourceSDK <- map["remoteSourceSDK"]
    }
}
