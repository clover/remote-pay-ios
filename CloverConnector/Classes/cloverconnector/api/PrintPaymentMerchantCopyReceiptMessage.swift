//
//  PrintPaymentMerchantCopyReceiptMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK

@objc
public class PrintPaymentMerchantCopyReceiptMessage : NSObject {
    public var payment:CLVModels.Payments.Payment?
    
    public init (payment:CLVModels.Payments.Payment) {
        self.payment = payment
    }
    
}
