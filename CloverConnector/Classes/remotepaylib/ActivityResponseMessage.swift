//
//  ActivityResponseMessage.swift
//  Pods
//
//
//
import ObjectMapper

public class ActivityResponseMessage:Message {

    var resultCode:Int = 0
    var failReason:String?
    var message:String?
    
    var payload:String?
    var action:String
    
    init(action a:String?, resultCode rc:Int, payload p:String?, failReason:String?) {
        self.action = a ?? "<unknown>"
        self.resultCode = rc
        self.payload = p
        self.payload = failReason
        super.init(method: Method.ACTIVITY_RESPONSE)
    }
    
    public required init?(map:Map) {
        self.action = "<unknown>"
        super.init(method: Method.ACTIVITY_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        self.action <- map["action"]
        self.resultCode <- map["resultCode"]
        self.payload <- map["payload"]
        self.failReason <- map["failReason"]
        self.message <- map["message"]
    }
}
