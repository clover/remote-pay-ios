//
//  ConfirmPaymentMessage.swift
//  Pods
//
//  
//
//

import Foundation
import ObjectMapper

public class ConfirmPaymentMessage : Message {
    
    public var payment:CLVModels.Payments.Payment?
    public var challenges:[Challenge]?
    
    
    public required init?(map:Map) {
        super.init(method: Method.CONFIRM_PAYMENT_MESSAGE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        payment <- (map["payment"], Message.paymentTransform)
        challenges <- map["challenges"]// challenges aren't wrapped in an elements, otherwise would need to be (map["challenges"], CLVArrayTransform<Challenge>())
    }
}
