//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK


/**
 * Callback to the POS to request a payment receipt be printed
 */
public class PrintPaymentReceiptMessage : NSObject {
    public var order:CLVModels.Order.Order?
    public var payment:CLVModels.Payments.Payment?
    
    public init (payment:CLVModels.Payments.Payment, order:CLVModels.Order.Order) {
        self.payment = payment;
        self.order = order;
    }
}
