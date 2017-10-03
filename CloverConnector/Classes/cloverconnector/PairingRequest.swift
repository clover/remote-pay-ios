//
//  PairingRequest.swift
//  Pods
//
//  
//
//

import Foundation
import ObjectMapper

public class PairingRequest:Mappable {
    
    public var method:String = PairingCode.PAIRING_REQUEST
    public var serialNumber:String?
    public var name:String?
    public var authenticationToken:String?
    
    public init(name:String, serialNumber:String, token:String?) {
        self.name = name
        self.serialNumber = serialNumber
        self.authenticationToken = token
    }
    
    public required init?(map:Map) {
    }
    
    public func mapping(map:Map) {
        self.serialNumber <- map["serialNumber"]
        self.name <- map["name"]
        self.authenticationToken <- map["authenticationToken"]
        self.method <- map["method"]
    }
}
