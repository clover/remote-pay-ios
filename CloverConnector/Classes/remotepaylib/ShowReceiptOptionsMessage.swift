//  
//  ShowReceiptOptionsMessage.swift
//  CloverConnector
//
//  
//

import Foundation
import ObjectMapper

public class ShowReceiptOptionsMessage: Message {
    public var orderId: String?
    public var paymentId: String?
    public var refundId: String?
    public var creditId: String?
    public var disableCloverPrinting: Bool?
    public var payment: CLVModels.Payments.Payment?
    public var credit: CLVModels.Payments.Credit?
    public var refund: CLVModels.Payments.Refund?
    public var isReprint: Bool?
    
    init(orderId: String?, paymentId: String?, refundId: String?, creditId: String?, disableCloverPrinting: Bool?, payment: CLVModels.Payments.Payment?, credit: CLVModels.Payments.Credit?, refund: CLVModels.Payments.Refund?, isReprint: Bool?) {
        self.orderId = orderId
        self.paymentId = paymentId
        self.refundId = refundId
        self.creditId = creditId
        self.disableCloverPrinting = disableCloverPrinting
        self.payment = payment
        self.credit = credit
        self.refund = refund
        self.isReprint = isReprint
        super.init(method: .SHOW_RECEIPT_OPTIONS)
    }
    
    public init() {
        super.init(method: .SHOW_RECEIPT_OPTIONS)
    }
    
    public required init?(map: Map) {
        super.init(method: .SHOW_RECEIPT_OPTIONS)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        self.orderId <- map["orderId"]
        self.paymentId <- map["paymentId"]
        self.refundId <- map["refundId"]
        self.creditId <- map["creditId"]
        self.disableCloverPrinting <- map["disableCloverPrinting"]
        self.payment <- map["payment"]
        self.credit <- map["credit"]
        self.refund <- map["refund"]
        self.isReprint <- map["isReprint"]
    }
}

