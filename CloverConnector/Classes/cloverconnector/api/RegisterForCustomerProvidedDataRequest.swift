//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import ObjectMapper


public class RegisterForCustomerProvidedDataRequest: NSObject, Mappable  {
    public var configurations:[DataProviderConfig]
    
    public init(configurations:[DataProviderConfig]) {
        self.configurations = configurations
    }

    /// :nodoc:
    public required init?(map:Map) {
        configurations = [DataProviderConfig]()
        super.init()
    }
    
    /// :nodoc:
    public func mapping(map:Map) {
        configurations <- map["configurations"]
    }
}



