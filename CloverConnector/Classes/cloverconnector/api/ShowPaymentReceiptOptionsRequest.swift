//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper



/**
 options for displaying the receipt options screen
 */
public class ShowPaymentReceiptOptionsRequest {

  /*
  * Unique identifier
   */
  var orderId:String
  /*
  * Unique identifier
   */
  var paymentId:String

    public init(orderId:String, paymentId:String) {
        self.orderId = orderId
        self.paymentId = paymentId
    }
}

