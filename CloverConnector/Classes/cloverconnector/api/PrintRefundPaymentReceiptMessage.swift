//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK

/**
* Callback to the POS to request a refund payment receipt
 */
public class PrintRefundPaymentReceiptMessage : NSObject {
    public var payment:CLVModels.Payments.Payment?
    public var refund:CLVModels.Payments.Refund?
    public var order:CLVModels.Order.Order?
    
    public init(payment:CLVModels.Payments.Payment, order:CLVModels.Order.Order, refund:CLVModels.Payments.Refund) {
        self.payment = payment;
        self.order = order;
        self.refund = refund;
    }
}
