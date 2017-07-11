//
//  DeviceStatusRequest.swift
//  Pods
//
//
//
import ObjectMapper

public class DeviceStatusRequest:Mappable {
    public var sendLastMessage:Bool = false
    
    public required init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        sendLastMessage <- map["sendLastMessage"]
    }
}
