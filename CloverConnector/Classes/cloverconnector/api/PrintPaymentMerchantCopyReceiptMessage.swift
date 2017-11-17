//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK

/**
* Callback to the POS to request a merchant copy of the payment receipt
 */
public class PrintPaymentMerchantCopyReceiptMessage : NSObject {
    public var payment:CLVModels.Payments.Payment?
    
    public init (payment:CLVModels.Payments.Payment) {
        self.payment = payment
    }
    
}
