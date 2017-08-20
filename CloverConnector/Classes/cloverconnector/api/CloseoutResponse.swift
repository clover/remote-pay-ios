//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 response to a closeout request
 */
public class CloseoutResponse:BaseResponse {

  /**
   * The batch that was closed out.
   */
  public var batch:CLVModels.Payments.Batch?


    public init(batch:CLVModels.Payments.Batch?, success:Bool, result:ResultCode) {
        super.init(success: success, result: result)
        self.batch = batch
    }
    
    /// :nodoc:
    required public init?(_ map: Map) {
        super.init(map)
    }
    /// :nodoc:
    public override func mapping(map: Map) {
        super.mapping(map)
        batch <- map["batch"]
    }
}

