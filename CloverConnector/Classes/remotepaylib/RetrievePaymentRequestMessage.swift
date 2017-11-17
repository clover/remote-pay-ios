//
//  RetrievePaymentRequestMessage.swift
//  Pods
//
//
//
import ObjectMapper

public class RetrievePaymentRequestMessage:Message {
    public var externalPaymentId:String = ""
    
    public init(_ externalPaymentId:String) {
        self.externalPaymentId = externalPaymentId
        super.init(method: Method.RETRIEVE_PAYMENT_REQUEST)
    }
    
    public required init?(map:Map) {
        super.init(map: map)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        self.externalPaymentId <- map["externalPaymentId"]
    }
}
