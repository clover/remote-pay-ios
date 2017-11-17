//
//  ExternalDeviceStateData.swift
//  Pods
//
//
//

import ObjectMapper

public class ExternalDeviceStateData:Mappable {
    public var externalPaymentId:String?
    public var customActivityId:String?
    
    public init(externalPaymentId epi:String?, customActivityId cai:String?) {
        self.externalPaymentId = epi
        self.customActivityId = cai
    }
    
    public init() {
        
    }
    
    public required init?(map:Map) {
        
    }
    
    public func mapping(map:Map) {
        externalPaymentId <- map["externalPaymentId"]
        customActivityId <- map["customerActivityId"]
    }
}

