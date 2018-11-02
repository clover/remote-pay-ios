//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

public class CustomerInfoMessage: Message {
    public var customer:CLVModels.Customers.CustomerInfo?
    
    public init(customer:CLVModels.Customers.CustomerInfo?) {
        self.customer = customer
        super.init(method: Method.CUSTOMER_INFO_MESSAGE)
    }
    
    public required init?(map:Map) {
        super.init(method: Method.CUSTOMER_INFO_MESSAGE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        customer <- (map["customer"], CLVTransforms.Customer.customerInfo)
    }
    
}





