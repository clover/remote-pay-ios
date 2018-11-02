//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

public class DataProviderConfig:Mappable  {
    
    public var type:String?
    public var configuration:[String:String]?
    
    
    public init(type:String?, configuration:[String:String]? = nil) {
        self.type = type
        self.configuration = configuration
    }
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        type <- map["type"]
        configuration <- map["configuration"]
    }
}
