//
//  CustomActivityRequest.swift
//  Pods
//
//
//
import ObjectMapper

public class CustomActivityRequest : BaseActivityMessage, Mappable {
    public var nonBlocking:Bool?
    
    public init(_ action:String, payload p:String?, nonBlocking nb:Bool = false) {
        super.init(action: action, payload: p)
        nonBlocking = nb
    }
    
    public required init?(_ map: Map) {
        super.init(action: "")
    }
    
    public func mapping(map: Map) {
        action <- map["action"]
        payload <- map["payload"]
        nonBlocking <- map["nonBlocking"]
    }
    
}
