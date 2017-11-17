//
//  POSStore.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import CloverConnector

public class POSStore {
    public var orders = [POSOrder]()
    public var currentOrder:POSOrder? = nil
    public var availableItems = [POSItem]()
    public var preAuths = [POSPayment]()
    public var vaultedCards = [POSCard]()
    public var manualRefunds = [POSNakedRefund]()
    
    fileprivate var storeListeners:NSMutableArray = NSMutableArray()
    fileprivate var orderListeners:NSMutableArray = NSMutableArray()
    
    public var transactionSettings = CLVModels.Payments.TransactionSettings()
    
    public var cardNotPresent:Bool?

    public func newOrder() {
        if let co = currentOrder {
            co.clearListeners();
        }
        currentOrder = POSOrder()
        for ol in orderListeners {
            if let listener = ol as? POSOrderListener {
                currentOrder?.addListener(listener)
            }
        }
        if let currentOrder = currentOrder {
            orders.append(currentOrder);
            
            for sl in storeListeners {
                if let listener = sl as? POSStoreListener {
                    listener.newOrderCreated(currentOrder)
                }
            }
        }
        
    }
    
    init() {

        newOrder()
        self.transactionSettings.cardEntryMethods = (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector?.CARD_ENTRY_METHODS_DEFAULT
    }
    
    public func addStoreListener(_ listener:POSStoreListener) {
        storeListeners.add(listener)
    }
    
    public func removeStoreListener(_ listener:POSStoreListener) {
        storeListeners.remove(listener)
    }
    
    public func addCurrentOrderListener(_ listener:POSOrderListener) {
        orderListeners.add(listener)
        currentOrder?.addListener(listener)
    }
    
    public func removeCurrentOrderListener(_ listener:POSOrderListener) {
        orderListeners.remove(listener)
        currentOrder?.removeListener(listener)
    }
    
    public func addPaymentToOrder(_ payment:POSPayment, order:POSOrder) {
        order.addPayment(payment)
    }
    
    public func addPreAuth(_ payment:POSPayment) {
        preAuths.append(payment)
        for sl in storeListeners {
            if let listener = sl as? POSStoreListener {
                listener.preAuthAdded(payment)
            }
        }
    }
    
    public func removePreAuth(_ payment:POSPayment) {
        let index = preAuths.index { (currentPayment) -> Bool in
            return payment.paymentId == currentPayment.paymentId
        }
        if let idx = index {
            
            preAuths.remove(at: idx)
            for sl in storeListeners {
                if let listener = sl as? POSStoreListener {
                    listener.preAuthRemoved(payment)
                }
            }
        } else {
            debugPrint("Couldn't find PreAuth to remove")
        }

    }
    
    public func addVaultedCard(_ card:POSCard) {
        vaultedCards.append(card)
        for sl in storeListeners {
            if let listener = sl as? POSStoreListener {
                listener.vaultCardAdded(card)
            }
        }
    }
    
    public func addRefundToOrder(_ refund:POSRefund, order:POSOrder) {
        order.addRefund(refund)
        for ol in orderListeners {
            if let listener = ol as? POSOrderListener {
                listener.refundAdded(refund)
            }
        }
    }

    public func addManualRefund(_ manualRefund:POSNakedRefund) {
        manualRefunds.append(manualRefund)
        for ol in storeListeners {
            if let listener = ol as? POSStoreListener {
                listener.manualRefundAdded(manualRefund)
            }
        }
    }
}

public protocol POSStoreListener:AnyObject {
    func newOrderCreated(_ order:POSOrder)
    func preAuthAdded(_ payment:POSPayment)
    func preAuthRemoved(_ payment:POSPayment)
    func vaultCardAdded(_ card:POSCard)
    func manualRefundAdded(_ credit:POSNakedRefund)
}
