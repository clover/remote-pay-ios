//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 response to a pre-auth request
 */
public class PreAuthResponse:PaymentResponse {
    public init(success:Bool, result:ResultCode) {
        super.init(success:success, result:result)
    }
    /// :nodoc:
    required public init?(map:Map) {
        super.init(map: map)
    }

}

