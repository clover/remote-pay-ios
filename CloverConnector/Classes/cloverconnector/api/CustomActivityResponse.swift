//
//  CustomActivityResponse.swift
//  Pods
//
//
//
import ObjectMapper

public class CustomActivityResponse : BaseResponse {
    public var action:String?
    public var payload:String?
    
    init(success s:Bool, result r:ResultCode, action a:String?, payload p:String?) {
        super.init(success: s, result: r)
        self.action = a
        self.payload = p
    }
    
    required public init?(_ map: Map) {
        super.init(map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        action <- map["action"]
        payload <- map["payload"]
    }
}
