//
//  PrintManualRefundDeclineReceiptMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK

@objc
public class PrintManualRefundDeclineReceiptMessage : NSObject {
    public var credit:CLVModels.Payments.Credit?
    public var reason:String?
    
    public init(credit:CLVModels.Payments.Credit?, reason:String?) {
        self.credit = credit;
        self.reason = reason;
    }
}
