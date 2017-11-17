//
//  ActivityMessageToActivity.swift
//  Pods
//
//
//

import ObjectMapper

public class BaseActivityRemoteMessage:Message {
    public var action:String
    public var payload:String?
    
    public init(action a:String, payload p:String?, method m: Method) {
        self.action = a
        self.payload = p
        super.init(method: m)
    }
    
    public required init?(map:Map) {
        return nil
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        action <- map["action"]
        payload <- map["payload"]
    }
}

public class ActivityMessageToActivity:BaseActivityRemoteMessage {
    
    public init(action a:String, payload p:String?) {
        super.init(action: a, payload: p, method: .ACTIVITY_MESSAGE_TO_ACTIVITY)
    }
    
    public required init?(map:Map) {
        super.init(action: "", payload: nil, method: .ACTIVITY_MESSAGE_TO_ACTIVITY)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
    }
}


