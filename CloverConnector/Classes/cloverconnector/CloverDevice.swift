//
//  CloverDevice.swift
//  CloverConnector
//
//  
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
    public typealias ImageClass = UIImage
    func ImagePNGRepresentation(_ image: ImageClass) -> Data? {
        return image.pngData()
    }
#else
    import AppKit
    public typealias ImageClass = NSImage
    func ImagePNGRepresentation(_ image: ImageClass) -> Data? {
        if let imageData = image.tiffRepresentation,
            let imageRep = NSBitmapImageRep(data: imageData) {
            return imageRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
        }
        return nil
    }
#endif


class CloverDevice {
    var deviceObservers = [CloverDeviceObserver]()
    
    weak var cloverConnector:ICloverConnector?
    
    var transport:CloverTransport
    var packageName:String? = nil
    
    var supportsAcks:Bool?
    var supportsVoidPaymentResponse:Bool?
    
    init (packageName:String, transport:CloverTransport) {
        self.transport = transport
        self.packageName = packageName
    }
    
    func subscribe(_ observer:CloverDeviceObserver) {
        deviceObservers.append(observer)
    }
    
    func unsubscribe(_ observer:CloverDeviceObserver) {
        guard let index = deviceObservers.firstIndex(where: {$0 === observer}) else { return }
        deviceObservers.remove(at: index)
    }
    
    deinit {
        CCLog.d("deinit CloverDevice")
    }
    
    func initialize() {}
    
    func doDiscoveryRequest() {}
    
    func doTxStart(_ payIntent:PayIntent, order:CLVModels.Order.Order?, requestInfo:String?) {}
    
    func doKeyPress(_ keyPress:KeyPress) {}
    
    func doVoidPayment(_ payment:CLVModels.Payments.Payment, reason:String, disablePrinting:Bool?, disableReceiptSelection:Bool?) {}
    
    func doVoidPaymentRefund(_ refundId: String, orderId: String?, disablePrinting: Bool?, disableReceiptSelection: Bool?) {}

    func doCaptureAuth(payIntent:PayIntent, order:CLVModels.Order.Order?, requestInfo ri:String?) {}
    
    func doCaptureAuth(_ paymentID:String, amount:Int, tipAmount:Int) {}
    
    func doIncrementPreAuth(_ amount:Int, paymentId: String) {}
    
    func doOrderUpdate(_ displayOrder:DisplayOrder, orderOperation operation:DisplayOrderModifiedOperation?) {}
    
    func doSignatureVerified(_ payment:CLVModels.Payments.Payment, verified:Bool) {}
    
    func doTerminalMessage(_ text:String) {}
    
    func doSendDebugLog(_ message:String) {}
    
    func doPaymentRefund(_ orderId:String?, paymentId:String?, amount:Int?, fullRefund:Bool?, disablePrinting:Bool?, disableReceiptSelection:Bool?) {} // manual refunds are handled via doTxStart
    
    func doTipAdjustAuth(_ orderId:String, paymentId:String, amount:Int) {}
    
    func doBreak() {}
    
    func doPrintText(_ textLines:[String], printRequestId: String?, printDeviceId: String?) {}
    
    func doShowWelcomeScreen() {}
    
    func doShowPaymentReceiptScreen(_ orderId:String, paymentId:String) {}
    
    func doShowReceiptScreen(orderId: String?, paymentId: String?, refundId: String?, creditId: String?, disablePrinting: Bool?) {}
    
    func doShowThankYouScreen() {}
    
    func doOpenCashDrawer(_ reason:String?, deviceId: String?) {}
    
    func doPrintImage(_ img:ImageClass, printRequestId: String?, printDeviceId: String?) {}
    
    func doPrintImage(_ url:String, printRequestId: String?, printDeviceId: String?) {}
    
    func doPrint(_ request:PrintRequest) {}
    
    func doRetrievePrinters(_ request:RetrievePrintersRequest) {}
    
    func doRetrievePrintJobStatus(_ request: PrintJobStatusRequest) {}
    
    func dispose() {
        deviceObservers.removeAll()
    }
    
    func doCloseout(_ allowOpenTabs:Bool, batchId:String?) {}
    
    func doVaultCard(_ cardEntryMethods:Int) {}
    
    func doAcceptPayment( _ payment:CLVModels.Payments.Payment) {}
    
    func doRejectPayment( _ payment:CLVModels.Payments.Payment, challenge:Challenge) {}
    
    func doRetrievePendingPayments() {}
    
    func doReadCardData(_ payIntent:PayIntent) {}
    
    func doStartActivity( action a:String, payload p:String?, nonBlocking:Bool) {}
    
    func doSendMessageToActivity( action a:String, payload p:String?) {}
    
    func doRetrievePayment(_ externalPaymentId:String) {}
    
    func doRetrieveDeviceStatus(_ sendLast:Bool) {}
    
    func doRegisterForCustomerProvidedData(_ configurations:[CLVModels.Loyalty.LoyaltyDataConfig]) {}
    
    func doSetCustomerInfo(_ customerInfo:CLVModels.Customers.CustomerInfo?) {}
}
