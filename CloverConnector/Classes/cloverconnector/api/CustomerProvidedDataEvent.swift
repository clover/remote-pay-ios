//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//


import ObjectMapper

/// Loyalty API
/// Transfers the data provided by the customer to the semi-integrated POS
public class CustomerProvidedDataEvent : BaseResponse {
    /// The ID of the data event.  The content of this value is defined by the data source of the loyalty data.
    public var eventId:String?
    /// The configuration of the data provided.  The content of this value is defined by the data source of the loyalty data.
    public var config:DataProviderConfig?
    /// Loyalty data provided by the loyalty data source.  The content of this value is defined by the data source of the loyalty data.
    public var data:String?
    
    init(success s:Bool, result r:ResultCode, eventId:String?, config:DataProviderConfig?, data:String?) {
        super.init(success: s, result: r)
        self.eventId = eventId
        self.config = config
        self.data = data
    }
    /// :nodoc:
    required public init?(map:Map) {
        super.init(map: map)
    }
    /// :nodoc:
    public override func mapping(map:Map) {
        super.mapping(map: map)
        eventId <- map["eventId"]
        config <- (map["config"], Message.dataProviderConfigTransform)
        data <- map["data"]
    }
}

