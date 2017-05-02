//
//  POSPayment.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public class POSPayment:POSExchange {
    public var type:PaymentType = PaymentType.PAYMENT
    public var status:PaymentStatus = PaymentStatus.UNKNOWN
    
    public var tipAmount:Int?
    public var cashbackAmount:Int?
    public var externalPaymentId:String?
    
    public init(paymentId:String, externalPaymentId:String?, orderId:String, employeeId:String, amount:Int, tipAmount:Int, cashbackAmount:Int) {
        self.externalPaymentId = externalPaymentId
        self.tipAmount = tipAmount
        self.cashbackAmount = cashbackAmount
        super.init(orderId: orderId, paymentId: paymentId, employeeId: employeeId, amount: amount)
    }
    
}

public enum PaymentType :String {
    case PAYMENT = "PAYMENT"
    case CREDIT = "CREDIT"
    case REFUND = "REFUND"
}

public enum PaymentStatus:String {
    case REFUNDED = "REFUNDED"
    case VOIDED = "VOIDED"
    case AUTHORIZED = "AUTHORIZED"
    case PREAUTHORIZED = "PREAUTHORIZED"
    case PAID = "PAID"
    case UNKNOWN = "UNKNOWN"
}
