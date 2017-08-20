//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 response to a read card data request
 */
public class ReadCardDataResponse : BaseResponse
{
    /// the card data object
    public var cardData:CardData? = nil
    
    public override init(success:Bool, result:ResultCode) {
        super.init(success:success, result: result);
    }
    public init(cardData:CardData?, code:ResultStatus, reason:String?) {
        super.init(success:code == .SUCCESS, result:code == .SUCCESS ? ResultCode.SUCCESS : ResultCode.FAIL)
        self.cardData = cardData
    }
    /// :nodoc:
    required public init?(_ map: Map) {
        super.init(map)
    }
    /// :nodoc:
    public override func mapping(map: Map) {
        super.mapping(map)
        cardData <- map["cardData"]
    }
}
