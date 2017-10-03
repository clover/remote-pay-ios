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
    public var date = Date()
    
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
    
    public fileprivate(set) var items = [POSLineItem]() // line items
    public fileprivate(set) var discounts = [POSDiscount]()
    public fileprivate(set) var payments = [POSPayment]()
    public fileprivate(set) var refunds = [POSRefund]()
    
    // transient reference to the payment id being requested
    public var pendingPaymentId:String?

    
    public func addListener(_ listener:POSOrderListener) {
        orderListeners.add(listener)
    }
    
    public func removeListener(_ listener:POSOrderListener) {
        orderListeners.remove(listener)
    }
    
    public func clearListeners() {
        orderListeners.removeAllObjects()
    }
    
    public func getTotal() -> Int {
        return getSubtotal() + getTaxAmount()
    }
    
    public func getSubtotal() -> Int {
        var subTotal:Int = 0
        for item in items {
            subTotal += item.afterDiscountPrice() * item.quantity
        }
        return subTotal
    }
    
    public func getTippableAmount() -> Int {
        var tippableAmount:Int = 0
        for item in items {
            if item.item.tippable {
                tippableAmount += item.afterDiscountPrice() * item.quantity
            }
        }
        return tippableAmount
    }
    
    public func getTaxAmount() -> Int {
        var tax:Float = 0
        
        for item in items {
            tax += Float(item.afterDiscountPrice() * item.quantity) * item.item.taxRate
        }
        return Int(tax)
    }
    
    public func getTipAmount() -> Int {
        var tipAmount:Int64 = 0
        for payment in payments {
            if(payment.status == PaymentStatus.PAID || payment.status == PaymentStatus.AUTHORIZED) {
                if(payment.type == PaymentType.PAYMENT) {
                    if let paymentTip = payment.tipAmount {
                        tipAmount += Int64(paymentTip)
                    }
                }
            }
        }
        return Int(tipAmount)
    }
    
    public func amountPaid() -> Int {
        var amountPaid:Int64 = 0
        for payment in payments {
            if(payment.status == PaymentStatus.PAID || payment.status == PaymentStatus.AUTHORIZED) {
                if(payment.type == PaymentType.PAYMENT) {
                    amountPaid += Int64(payment.amount)
                }
            }
        }
        return Int(amountPaid)
    }
    
    public func addPayment(_ payment:POSPayment) {
        payments.append(payment)
        notifyListenersPaymentAdded(payment)
    }
    
    public func removeLineItem(_ lineItem:POSLineItem) {
        lineItem.quantity -= 1
        
        if lineItem.quantity == 0 {
            if let index = items.index(where: { (li) -> Bool in
                return li === lineItem
            }) {
                items.remove(at: index)
                for listener in orderListeners {
                    if let listener = listener as? POSOrderListener {
                        listener.itemRemoved(lineItem)
                    }
                }
            }
            
            
        } else {
            for listener in orderListeners {
                if let listener = listener as? POSOrderListener {
                    listener.itemModified(lineItem)
                }
            }
        }
        
        
    }
    
    public func addLineItem(_ lineItem:POSLineItem) {
        var incrementingOnly = false
        for li in items {
            if li.item.id == lineItem.item.id {
                li.quantity += lineItem.quantity
                incrementingOnly = true
                for listener in orderListeners {
                    if let listener = listener as? POSOrderListener {
                        listener.itemModified(li)
                    }
                }
                break
            }
        }
        
        if !incrementingOnly {
            items.append(lineItem)
            
            for listener in orderListeners {
                if let listener = listener as? POSOrderListener {
                    listener.itemAdded(lineItem)
                }
            }
        }
    }
    
    public func addRefund(_ refund:POSRefund) {
        for payment in payments {
            if payment.paymentId == refund.paymentId {
                payment.status = .REFUNDED
                notifyListenersPaymentChanged(payment)
                break;
            }
        }
        refunds.append(refund)
        notifyListenersRefundAdded(refund)
    }
    
    
    fileprivate func notifyListenersPaymentAdded(_ payment:POSPayment) {
        for listener in orderListeners {
            if let listener = listener as? POSOrderListener {
                listener.paymentAdded(payment)
            }
        }
    }
    
    fileprivate func notifyListenersPaymentChanged(_ payment:POSPayment) {
        for listener in orderListeners {
            if let listener = listener as? POSOrderListener {
                listener.paymentChanged(payment)
            }
        }
    }
    
    
    fileprivate func notifyListenersRefundAdded(_ refund:POSRefund) {
        for listener in orderListeners {
            if let listener = listener as? POSOrderListener {
                listener.refundAdded(refund)
            }
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
