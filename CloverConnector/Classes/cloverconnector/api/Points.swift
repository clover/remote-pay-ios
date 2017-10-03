//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public class Points:Mappable {

  var points:[Point] = [Point]()
/// :nodoc:
  public required init() {

  }
/// :nodoc:
  required public init?(map:Map) {
  }
/// :nodoc:
  public func mapping(map:Map) {
    points <- map["points"]

  }
}

