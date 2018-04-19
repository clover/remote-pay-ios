//
//  CloverConnectorBroadcaster.swift
//  CloverConnector
//
//  
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import Foundation


public class CloverConnectorBroadcaster {
    
    // Array of the ICloverConnectorListeners that will each be notified upon request
    private var listeners = [ICloverConnectorListener]()
    
    // The DispatchQueue that each notification will take place on.  Used to make the listeners array thread safe.
    private var dispatchQueue = DispatchQueue(label: "com.clover.cloverconnectorbroadcaster.\(UUID().uuidString)")
    
    // Adds a listener to be notified
    public func addObject(_ listener:ICloverConnectorListener) {
        dispatchQueue.async { [weak self] in
            if self?.listeners.index(where: {$0 === listener}) == nil {
                self?.listeners.append(listener)
            }
        }
    }
    
    // Removes all listeners
    public func clearAll() {
        dispatchQueue.async { [weak self] in
            self?.listeners.removeAll()
        }
    }
    
    // Removes a single listener
    public func removeObject(_ listener:ICloverConnectorListener) {
        dispatchQueue.async { [weak self] in
            if let index = self?.listeners.index(where: {$0 === listener}) {
                self?.listeners.remove(at: index)
            }
        }
    }
    
    public func notifyOnTipAdded(_ tip:Int) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onTipAdded(TipAddedMessage(tip))
            }
        }
    }
    
    public func notifyOnPaymentRefundResponse(_ refundPaymentResponse:RefundPaymentResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onRefundPaymentResponse(refundPaymentResponse)
            }
        }
    }
    
    public func notifyOnCloseoutResponse(_ closeoutResponse:CloseoutResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onCloseoutResponse(closeoutResponse)
            }
        }
    }
    
    public func notifyOnDeviceActivityStart(_ deviceEvent:CloverDeviceEvent) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onDeviceActivityStart(deviceEvent)
            }
        }
    }
    
    public func notifyOnDeviceActivityEnd(_ deviceEvent:CloverDeviceEvent) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onDeviceActivityEnd(deviceEvent)
            }
        }
    }
    
    public func notifyOnDeviceError(_ deviceError:CloverDeviceErrorEvent) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onDeviceError(deviceError);
            }
        }
    }
    
    public func notifyOnSaleResponse(_ response:SaleResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onSaleResponse(response)
            }
        }
    }
    
    public func notifyOnAuthResponse(_ response:AuthResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onAuthResponse(response)
            }
        }
    }
    
    public func notifyOnManualRefundResponse(_ response:ManualRefundResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onManualRefundResponse(response)
            }
        }
    }
    
    public func notifyOnVerifySignatureRequest(_ request:VerifySignatureRequest) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onVerifySignatureRequest(request)
            }
        }
    }
    
    public func notifyOnConfirmPayment(_ request:ConfirmPaymentRequest) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onConfirmPaymentRequest(request)
            }
        }
    }
    
    public func notifyOnVoidPaymentResponse(_ response:VoidPaymentResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onVoidPaymentResponse(response)
            }
        }
    }
    
    public func notifyOnConnect() {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onDeviceConnected()
            }
        }
    }
    
    public func notifyOnDisconnect() {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onDeviceDisconnected()
            }
        }
    }
    
    public func notifyOnReady(_ merchantInfo:MerchantInfo) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onDeviceReady(merchantInfo)
            }
        }
    }
    
    public func notifyOnTipAdjustAuthResponse(_ response:TipAdjustAuthResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onTipAdjustAuthResponse(response);
            }
        }
    }
    
    public func notifyOnVaultCardRespose(_ ccr:VaultCardResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onVaultCardResponse(ccr)
            }
        }
    }
    
    public func notifyOnPreAuthResponse(_ response:PreAuthResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onPreAuthResponse(response)
            }
        }
    }
    

    
    public func notifyOnCapturePreAuth(_ response:CapturePreAuthResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onCapturePreAuthResponse(response)
            }
        }
    }
    
    public func notifyOnPendingPaymentsResponse(_ response:RetrievePendingPaymentsResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onRetrievePendingPaymentsResponse(response)
            }
        }
    }
    
    public func notifyPrintCredit(_ response:PrintManualRefundReceiptMessage) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onPrintManualRefundReceipt(response)
            }
        }
    }
    
    public func notifyPrintCreditDecline(_ response:PrintManualRefundDeclineReceiptMessage) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onPrintManualRefundDeclineReceipt(response)
            }
        }
    }
    
    
    public func notifyOnPrintMerchantReceipt(_ response: PrintPaymentMerchantCopyReceiptMessage) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onPrintPaymentMerchantCopyReceipt(response)
            }
        }
    }
    
    public func notifyOnPrintPaymentReceipt(_ response: PrintPaymentReceiptMessage) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onPrintPaymentReceipt(response)
            }
        }
    }
    
    public func notifyOnPrintPaymentDeclineReceipt(_ response: PrintPaymentDeclineReceiptMessage) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onPrintPaymentDeclineReceipt(response)
            }
        }
    }
    
    public func notifyOnPrintPaymentRefund(_ response: PrintRefundPaymentReceiptMessage) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onPrintRefundPaymentReceipt(response)
            }
        }
    }
    
    public func notifyOnReadCardResponse(_ response: ReadCardDataResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onReadCardDataResponse(response)
            }
        }
    }
    
    public func notifyOnCustomActivityResponse(_ response: CustomActivityResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onCustomActivityResponse(response)
            }
        }
    }
    
    public func notifyOnMessageFromActivity(_ message:MessageFromActivity) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onMessageFromActivity(message)
            }
        }
    }
    
    public func notifyOnResetDeviceResponse(_ response:ResetDeviceResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onResetDeviceResponse(response)
            }
        }
    }
    
    public func notifyOnRetrievePrintersResponse(_ response:RetrievePrintersResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onRetrievePrintersResponse(response)
            }
        }
    }
    
    public func notifyOnPrintJobStatusResponse(_ response:PrintJobStatusResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onPrintJobStatusResponse(response)
            }
        }
    }

    public func notifyOnRetrievePayment(_ response:RetrievePaymentResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onRetrievePaymentResponse(response)
            }
        }
    }
    
    public func notifyOnDeviceStatusResponse(_ response:RetrieveDeviceStatusResponse) {
        dispatchQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            for listener in strongSelf.listeners {
                listener.onRetrieveDeviceStatusResponse(response)
            }
        }
    }
}
