//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public class ResultStatusEnum:Mappable {

  var status:ResultStatus? = nil 

  public required init() {

  }
  /// :nodoc:
  required public init?(map:Map) {
  }
    
  /// :nodoc:
  public func mapping(map:Map) {
  status <- map["status"]

  }

}

