//
//  RetrieveDeviceStatusRequestMessage.swift
//  Pods
//
//
//

import ObjectMapper

public class RetrieveDeviceStatusRequestMessage:Message {
    public var sendLastMessage:Bool = false
    
    public init(_ sendLastMessage:Bool) {
        self.sendLastMessage = sendLastMessage
        super.init(method: Method.RETRIEVE_DEVICE_STATUS_REQUEST)
    }
    
    public required init?(map:Map) {
        super.init(method: Method.RETRIEVE_DEVICE_STATUS_REQUEST)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        sendLastMessage <- map["sendLastMessage"]
    }
}
