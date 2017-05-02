//
//  ReadCardDataResponse.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

public class ReadCardDataResponse : BaseResponse
{
    public var cardData:CardData? = nil
    
    public override init(success:Bool, result:ResultCode) {
        super.init(success:success, result: result);
    }
    public init(cardData:CardData?, code:ResultStatus, reason:String?) {
        super.init(success:code == .SUCCESS, result:code == .SUCCESS ? ResultCode.SUCCESS : ResultCode.FAIL)
        self.cardData = cardData
    }
    
    required public init?(_ map: Map) {
        super.init(map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        cardData <- map["cardData"]
    }
}
