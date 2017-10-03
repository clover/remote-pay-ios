//
//  CloverConnectorBroadcaster.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDKRemotepay


public class CloverConnectorBroadcaster {
    var listeners = NSMutableArray()
    
    public func addObject(_ listener:ICloverConnectorListener) {
        if listeners.index(of: listener) != -1 {
            listeners.add(listener)
        }
    }
    
    public func removeObject(_ listener:ICloverConnectorListener) {
        listeners.remove(listener)
    }
    
    public func notifyOnTipAdded(_ tip:Int) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onTipAdded(TipAddedMessage(tip))
            }
        }
    }
    
    public func notifyOnPaymentRefundResponse(_ refundPaymentResponse:RefundPaymentResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onRefundPaymentResponse(refundPaymentResponse)
            }
        }
    }
    
    public func notifyOnCloseoutResponse(_ closeoutResponse:CloseoutResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onCloseoutResponse(closeoutResponse)
            }
        }
    }
    
    public func notifyOnDeviceActivityStart(_ deviceEvent:CloverDeviceEvent) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onDeviceActivityStart(deviceEvent)
            }
        }
    }
    
    public func notifyOnDeviceActivityEnd(_ deviceEvent:CloverDeviceEvent) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onDeviceActivityEnd(deviceEvent)
            }
        }
        
    }
    
    public func notifyOnDeviceError(_ deviceError:CloverDeviceErrorEvent) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onDeviceError(deviceError);
            }
        }
    }
    
    public func notifyOnSaleResponse(_ response:SaleResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener
            {
                listener.onSaleResponse(response)
            }
        }
    }
    
    public func notifyOnAuthResponse(_ response:AuthResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onAuthResponse(response)
            }
        }
    }
    
    public func notifyOnManualRefundResponse(_ response:ManualRefundResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onManualRefundResponse(response)
            }
        }
    }
    
    public func notifyOnVerifySignatureRequest(_ request:VerifySignatureRequest) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onVerifySignatureRequest(request)
            }
        }
    }
    
    public func notifyOnConfirmPayment(_ request:ConfirmPaymentRequest) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onConfirmPaymentRequest(request)
            }
        }
    }
    
    public func notifyOnVoidPaymentResponse(_ response:VoidPaymentResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onVoidPaymentResponse(response)
            }
        }
    }
    
    public func notifyOnConnect() {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onDeviceConnected()
            }
        }
    }
    
    public func notifyOnDisconnect() {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onDeviceDisconnected()
            }
        }
    }
    
    public func notifyOnReady(_ merchantInfo:MerchantInfo) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onDeviceReady(merchantInfo)
            }
        }
    }
    
    public func notifyOnTipAdjustAuthResponse(_ response:TipAdjustAuthResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onTipAdjustAuthResponse(response);
            }
        }
    }
    
//    public func notifyOnTxState(txState:TxState) {
    public func notifyOnTxState(_ txState:Any) {
//        for listener in listeners {
//            if let listener = listener as? ICloverConnectorListener {
//                listener.onTransactionState(txState)
//            }
//        }
    }
    
    public func notifyOnVaultCardRespose(_ ccr:VaultCardResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onVaultCardResponse(ccr)
            }
        }
    }
    
    public func notifyOnPreAuthResponse(_ response:PreAuthResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onPreAuthResponse(response)
            }
        }
    }
    

    
//    public func notifyOnCapturePreAuth(response:CaptureAuthResponse) {
    public func notifyOnCapturePreAuth(_ response:CapturePreAuthResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onCapturePreAuthResponse(response)

            }
        }
    }
    
    public func notifyOnPendingPaymentsResponse(_ response:RetrievePendingPaymentsResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onRetrievePendingPaymentsResponse(response)
                
            }
        }
    }
    
    public func notifyPrintCredit(_ response:PrintManualRefundReceiptMessage) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onPrintManualRefundReceipt(response)
            }
        }
    }
    
    public func notifyPrintCreditDecline(_ response:PrintManualRefundDeclineReceiptMessage) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onPrintManualRefundDeclineReceipt(response)
            }
        }
    }
    
    
    public func notifyOnPrintMerchantReceipt(_ response: PrintPaymentMerchantCopyReceiptMessage) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onPrintPaymentMerchantCopyReceipt(response)
            }
        }
    }
    
    public func notifyOnPrintPaymentReceipt(_ response: PrintPaymentReceiptMessage) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onPrintPaymentReceipt(response)
            }
        }
    }
    
    public func notifyOnPrintPaymentDeclineReceipt(_ response: PrintPaymentDeclineReceiptMessage) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onPrintPaymentDeclineReceipt(response)
            }
        }
    }
    
    public func notifyOnPrintPaymentRefund(_ response: PrintRefundPaymentReceiptMessage) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onPrintRefundPaymentReceipt(response)
            }
        }
    }
    
    public func notifyOnReadCardResponse(_ response: ReadCardDataResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onReadCardDataResponse(response)
            }
        }
    }
    
    public func notifyOnCustomActivityResponse(_ response: CustomActivityResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onCustomActivityResponse(response)
            }
        }
    }
    
    public func notifyOnMessageFromActivity(_ message:MessageFromActivity) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onMessageFromActivity(message)
            }
        }
    }
    
    public func notifyOnResetDeviceResponse(_ response:ResetDeviceResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onResetDeviceResponse(response)
            }
        }
    }
    
    public func notifyOnRetrievePrintersResponse(_ response:RetrievePrintersResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onRetrievePrintersResponse(response)
            }
        }
    }
    
    public func notifyOnPrintJobStatusResponse(_ response:PrintJobStatusResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onPrintJobStatusResponse(response)
            }
        }
    }

    public func notifyOnRetrievePayment(_ response:RetrievePaymentResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onRetrievePaymentResponse(response)
            }
        }
    }
    
    public func notifyOnDeviceStatusResponse(_ response:RetrieveDeviceStatusResponse) {
        for listener in listeners {
            if let listener = listener as? ICloverConnectorListener {
                listener.onRetrieveDeviceStatusResponse(response)
            }
        }
    }
    
}
