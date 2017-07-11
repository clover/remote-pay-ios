//
//  POSOrder.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public class POSOrder {
    public var orderNumber:Int = 0
    var orderListeners = NSMutableArray()
    public var date = NSDate()
    
    public var status:OrderStatus {
        get {
            if(items.count == 0) {
                return .READY
            } else if amountPaid() >= getTotal() {
                return .PAID
            } else if amountPaid() == 0 {
                return .OPEN
            } else {
                return .PARTIALLY_PAID
            }
        }
    }
    
    public private(set) var items:NSMutableArray = NSMutableArray() // line items
    public private(set) var discounts:NSMutableArray = NSMutableArray()
    public private(set) var payments:NSMutableArray = NSMutableArray()
    public private(set) var refunds:NSMutableArray = NSMutableArray()
    
    // transient reference to the payment id being requested
    public var pendingPaymentId:String?

    
    public func addListener(_ listener:POSOrderListener) {
        orderListeners.addObject(listener)
    }
    
    public func removeListener(_ listener:POSOrderListener) {
        orderListeners.removeObject(listener)
    }
    
    public func clearListeners() {
        orderListeners.removeAllObjects()
    }
    
    public func getTotal() -> Int {
        return getSubtotal() + getTaxAmount()
    }
    
    public func getSubtotal() -> Int {
        var subTotal:Int = 0
        for var item in items {
            if let posLineItem = item as? POSLineItem {
                subTotal += posLineItem.afterDiscountPrice() * posLineItem.quantity
            }
        }
        return subTotal
    }
    
    public func getTippableAmount() -> Int {
        var tippableAmount:Int = 0
        for var item in items {
            if let posLineItem = item as? POSLineItem {
                if posLineItem.item.tippable {
                    tippableAmount += posLineItem.afterDiscountPrice() * posLineItem.quantity
                }
            }
        }
        return tippableAmount
    }
    
    public func getTaxAmount() -> Int {
        var tax:Float = 0
        
        for var item in items {
            if let posLineItem = item as? POSLineItem {
                tax += Float(posLineItem.afterDiscountPrice() * posLineItem.quantity) * posLineItem.item.taxRate
            }
        }
        return Int(tax)
    }
    
    public func getTipAmount() -> Int {
        var tipAmount:Int64 = 0
        for var item in items {
            if let payment = item as? POSPayment {
                if(payment.status == PaymentStatus.PAID || payment.status == PaymentStatus.AUTHORIZED) {
                    if(payment.type == PaymentType.PAYMENT) {
                        if let paymentTip = payment.tipAmount {
                            tipAmount += paymentTip
                        }
                    }
                }
            }
        }
        return Int(tipAmount)
    }
    
    public func amountPaid() -> Int {
        var amountPaid:Int64 = 0
        for var item in items {
            if let payment = item as? POSPayment {
                if(payment.status == PaymentStatus.PAID || payment.status == PaymentStatus.AUTHORIZED) {
                    if(payment.type == PaymentType.PAYMENT) {
                        amountPaid += payment.amount
                    }
                }
            }
        }
        return Int(amountPaid)
    }
    
    public func addPayment(_ payment:POSPayment) {
        payments.addObject(payment)
        notifyListenersPaymentAdded(payment)
    }
    
    public func removeLineItem(_ lineItem:POSLineItem) {
        lineItem.quantity -= 1
        
        if lineItem.quantity == 0 {
            items.removeObject(lineItem)
            for var listener in orderListeners {
                (listener as? POSOrderListener)!.itemRemoved(lineItem)
            }
            
        } else {
            for var listener in orderListeners {
                (listener as? POSOrderListener)!.itemModified(lineItem)
            }
            
        }
        
        
    }
    
    public func addLineItem(_ lineItem:POSLineItem) {
        var incrementingOnly = false
        var newOrUpdatedLineItem:POSLineItem?
        for var li in items {
            if let lineI = li as? POSLineItem {
                if lineI.item.id == lineItem.item.id {
                    lineI.quantity += lineItem.quantity
                    incrementingOnly = true
                    for var listener in orderListeners {
                        (listener as? POSOrderListener)!.itemModified(lineI)
                    }
                    break
                }
            }
        }
        
        if !incrementingOnly {
            items.addObject(lineItem)
            
            for var listener in orderListeners {
                (listener as? POSOrderListener)!.itemAdded(lineItem)
            }
        }
    }
    
    public func addRefund(_ refund:POSRefund) {
        for var payment in payments {
            if let payment = payment as? POSPayment {
                if payment.paymentId == refund.paymentId {
                    payment.status = .REFUNDED
                    notifyListenersPaymentChanged(payment)
                    break;
                }
            }
        }
        refunds.addObject(refund)
        notifyListenersRefundAdded(refund)
    }
    
    
    private func notifyListenersPaymentAdded(_ payment:POSPayment) {
        for var listener in orderListeners {
            (listener as? POSOrderListener)!.paymentAdded(payment);
        }
    }
    
    private func notifyListenersPaymentChanged(_ payment:POSPayment) {
        for var listener in orderListeners {
            (listener as? POSOrderListener)!.paymentChanged(payment);
        }
    }
    
    
    private func notifyListenersRefundAdded(_ refund:POSRefund) {
        for var listener in orderListeners {
            (listener as? POSOrderListener)!.refundAdded(refund);
        }
    }
}

public enum OrderStatus : String {
    case OPEN = "OPEN"
    case PAID = "PAID"
    case PARTIALLY_PAID = "PARTIALLY PAID"
    case READY = "READY" // new order with nothing in it so it can be discarded if needed
    case UNKNOWN = "UNKNOWN"
}

public protocol POSOrderListener : AnyObject {
    func itemAdded(_ item:POSLineItem)
    func itemRemoved(_ item:POSLineItem)
    func itemModified(_ item:POSLineItem)
    func discountAdded(_ item:POSDiscount)
    func paymentAdded(_ item:POSPayment)
    func refundAdded(_ refund:POSRefund)
    func paymentChanged(_ item:POSPayment)
}
