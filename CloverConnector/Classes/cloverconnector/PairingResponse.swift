//
//  PairingResponse.swift
//  Pods
//
//  
//
//

import Foundation
import ObjectMapper

public class PairingResponse : PairingRequest {
    public var pairingState:String?
    public var applicationName:String?
    public var millis:Int?
    
    public init(name:String, serialNumber:String, pairingState:String, applicationName:String, authenticationToken:String,  millis:Int) {
        super.init(name: name, serialNumber: serialNumber, token: authenticationToken)
        self.pairingState = pairingState;
        self.applicationName = applicationName;
        self.millis = millis;
    }
    
    public required init?(map:Map) {
        super.init(map:map)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map:map)
        pairingState <- map["pairingState"]
        applicationName <- map["applicationName"]
        millis <- map["millis"]
    }
    
}
