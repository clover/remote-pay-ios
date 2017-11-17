//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK

/**
 * Callback to the POS to request a payment declined receipt
 */
public class PrintPaymentDeclineReceiptMessage : NSObject {
    public var payment:CLVModels.Payments.Payment?
    public var reason:String?
    
    public init(payment:CLVModels.Payments.Payment, reason:String) {
        self.payment = payment;
        self.reason = reason;
    }
    
}
