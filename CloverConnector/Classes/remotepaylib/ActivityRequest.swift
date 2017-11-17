//
//  ActivityMessage.swift
//  Pods
//
//
//
import ObjectMapper

public class ActivityRequest: Message {
    public var action:String
    public var payload:String?
    public var nonBlocking:Bool = false
    public var forceLaunch:Bool = false
    
    init(action a:String, payload p:String?, nonBlocking nb:Bool, forceLaunch fl:Bool) {
        self.action = a
        self.payload = p
        self.nonBlocking = nb
        self.forceLaunch = fl
        super.init(method: Method.ACTIVITY_REQUEST)
    }

    public required init?(map:Map) {
        action = ""
        super.init(method: Method.ACTIVITY_REQUEST)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        action <- map["action"]
        payload <- map["payload"]
        nonBlocking <- map["nonBlocking"]
        forceLaunch <- map["forceLaunch"]
    }
}
