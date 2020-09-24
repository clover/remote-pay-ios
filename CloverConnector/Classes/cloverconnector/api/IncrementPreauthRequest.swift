//  
//  IncrementPreauthRequest.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper

public class IncrementPreauthRequest: Mappable {
    /// The amount by which to increment the pre-auth.
    var amount: Int
    /// The preauth to be incremented. This id should be pulled from the Payment.paymentId field in the PreAuthResponse.
    var paymentId: String
    
    public init(amount: Int, paymentId: String) {
        self.amount = amount
        self.paymentId = paymentId
    }
    
    public required init?(map: Map) {
        amount = 0
        paymentId = ""
    }
    
    public func mapping(map: Map) {
        amount <- map["amount"]
        paymentId <- map["paymentId"]
    }
}
