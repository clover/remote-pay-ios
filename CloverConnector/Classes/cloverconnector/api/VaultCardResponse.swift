//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 resonse to a vault card request
 */
public class VaultCardResponse:BaseResponse {

    /// the vaulted card
  public var card:CLVModels.Payments.VaultedCard? = nil

    public override init(success:Bool, result:ResultCode) {
        super.init(success:success, result: result);
    }
    public init(card:CLVModels.Payments.VaultedCard?, code:ResultStatus, reason:String?) {
        super.init(success:code == .SUCCESS, result:code == .SUCCESS ? ResultCode.SUCCESS : ResultCode.FAIL)
        self.card = card
    }
    /// :nodoc:
    required public init?(map:Map) {
        super.init(map: map)
    }
    /// :nodoc:
    public override func mapping(map:Map) {
        super.mapping(map: map)
        card <- map["card"]
    }
}

