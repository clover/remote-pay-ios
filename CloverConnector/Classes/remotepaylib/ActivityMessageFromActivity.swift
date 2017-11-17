//
//  ActivityMessageFromActivity.swift
//  Pods
//
//
//
import ObjectMapper

public class ActivityMessageFromActivity:BaseActivityRemoteMessage {
    
    public init(action a:String, payload p:String?) {
        super.init(action: a, payload: p, method: .ACTIVITY_MESSAGE_TO_ACTIVITY)
    }
    
    public required init?(map:Map) {
        super.init(action: "", payload: nil, method: .ACTIVITY_MESSAGE_FROM_ACTIVITY)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
    }
}

