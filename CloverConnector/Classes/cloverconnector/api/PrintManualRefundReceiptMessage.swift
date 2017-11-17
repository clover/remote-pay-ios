//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK

/**
 * Callback to request the POS print a refund for a
 * ManualRefund
 */
public class PrintManualRefundReceiptMessage : NSObject {
    public var credit:CLVModels.Payments.Credit?
    
    public init(credit:CLVModels.Payments.Credit)
    {
        self.credit = credit;
        super.init()
    }
    
}
