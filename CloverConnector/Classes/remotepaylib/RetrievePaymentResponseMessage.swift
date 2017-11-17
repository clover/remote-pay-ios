//
//  RetrievePaymentResponseMessage.swift
//  Pods
//
//

import ObjectMapper

public class RetrievePaymentResponseMessage:Message {
    public var result:ResultStatus = .FAIL
    public var reason:String?
    public var queryStatus:QueryStatus
    public var externalPaymentId:String?
    public var payment:CLVModels.Payments.Payment?
    
    public init(success s: Bool, result r: ResultStatus, queryStatus qs: QueryStatus, externalPaymentId epi:String?, payment p:CLVModels.Payments.Payment?) {
        self.queryStatus = qs
        self.externalPaymentId = epi
        self.payment = p
        self.result = r
        self.reason = ""
        super.init(method: .RETRIEVE_PAYMENT_RESPONSE)
    }
    
    public required init?(map:Map) {
        queryStatus = .NOT_FOUND
        super.init(method: .RETRIEVE_PAYMENT_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        queryStatus <- map["queryStatus"]
        externalPaymentId <- map["externalPaymentId"]
        payment <- (map["payment"], Message.paymentTransform)
    }
}
