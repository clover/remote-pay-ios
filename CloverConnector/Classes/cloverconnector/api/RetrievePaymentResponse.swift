//
//  RetrievePaymentResponse.swift
//  Pods
//
//
//
import ObjectMapper

public class RetrievePaymentResponse:BaseResponse {
    public var queryStatus:QueryStatus
    public var externalPaymentId:String?
    public var payment:CLVModels.Payments.Payment?
    
    public init(success s:Bool, result r:ResultCode, queryStatus qs:QueryStatus, payment p:CLVModels.Payments.Payment?, externalPaymentId epi:String?) {
        self.queryStatus = qs
        super.init(success: s, result: r)
        self.payment = p
        self.externalPaymentId = epi
    }
    
    required public init?(_ map: Map) {
        self.queryStatus = .NOT_FOUND
        super.init(success: false, result: .FAIL)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        self.payment <- map["payment"]
    }
}
