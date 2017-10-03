//
//  DeviceStatusRequest.swift
//  Pods
//
//
//
import ObjectMapper

public class DeviceStatusRequest:Mappable {
    public var sendLastMessage:Bool = false
    
    public required init?(map:Map) {
        
    }
    
    public func mapping(map:Map) {
        sendLastMessage <- map["sendLastMessage"]
    }
}
