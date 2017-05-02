//
//  CloverDevice.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

protocol ICloverDevice {
}

class CloverDevice {
    var deviceObservers:NSMutableArray = NSMutableArray()
    
    var transport:CloverTransport
    var packageName:String? = nil
    
    init (packageName:String, transport:CloverTransport) {
        self.transport = transport
        self.packageName = packageName
    }
    
    func subscribe(_ observer:CloverDeviceObserver) {
        deviceObservers.addObject(observer)
    }
    
    func unsubscribe(_ observer:CloverDeviceObserver) {
        deviceObservers.removeObject(observer)
    }
    
    func doDiscoveryRequest() {}
    
    func doTxStart(_ payIntent:PayIntent, order:CLVModels.Order.Order?, suppressTipScreen:Bool) {}
    
    func doKeyPress(_ keyPress:KeyPress) {}
    
    func doVoidPayment(_ payment:CLVModels.Payments.Payment, reason:String) {}
    
    func doCaptureAuth(_ paymentID:String, amount:Int, tipAmount:Int) {}
    
    func doOrderUpdate(_ displayOrder:DisplayOrder, orderOperation operation:DisplayOrderModifiedOperation?) {}
    
    func doSignatureVerified(_ payment:CLVModels.Payments.Payment, verified:Bool) {}
    
    func doTerminalMessage(_ text:String) {}
    
    func doPaymentRefund(_ orderId:String, paymentId:String, amount:Int, fullRefund:Bool) {} // manual refunds are handled via doTxStart
    
    func doTipAdjustAuth(_ orderId:String, paymentId:String, amount:Int) {}
    
    func doBreak() {}
    
    func doPrintText(_ textLines:[String]) {}
    
    func doShowWelcomeScreen() {}
    
    func doShowPaymentReceiptScreen(_ orderId:String, paymentId:String) {}
    
    func doShowThankYouScreen() {}
    
    func doOpenCashDrawer(_ reason:String) {}
    
    //func doPrintImage(_ bitmap:UIImage) {}
    func doPrintImage(_ url:String) {}
    
    func dispose() {}
    
    func doCloseout(_ allowOpenTabs:Bool, batchId:String?) {}
    
    func doVaultCard(_ cardEntryMethods:Int) {}
    
    func doAcceptPayment( _ payment:CLVModels.Payments.Payment) {}
    
    func doRejectPayment( _ payment:CLVModels.Payments.Payment, challenge:Challenge) {}
    
    func doRetrievePendingPayments() {}
    
    func doReadCardData(_ payIntent:PayIntent) {}
    
}
