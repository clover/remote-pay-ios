//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDK

/**
 * Callback to the POS to request a manual refund declined receipt
 */
public class PrintManualRefundDeclineReceiptMessage : NSObject {
    /// the credit
    public var credit:CLVModels.Payments.Credit?
    /// the decline reason
    public var reason:String?
    
    public init(credit:CLVModels.Payments.Credit?, reason:String?) {
        self.credit = credit;
        self.reason = reason;
    }
}
