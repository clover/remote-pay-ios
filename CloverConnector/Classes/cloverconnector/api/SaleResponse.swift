//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 * response to a sale request
 */
public class SaleResponse:PaymentResponse {
    public init(success:Bool, result:ResultCode) {
        super.init(success:success, result:result)
    }
    
    /// :nodoc:
    required public init?(map:Map) {
        super.init(map: map)
    }
    /// :nodoc:
    public override func mapping(map:Map) {
        super.mapping(map: map)
    }
}

