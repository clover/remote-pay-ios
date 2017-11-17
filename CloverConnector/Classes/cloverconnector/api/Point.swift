//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper




public class Point:Mappable {

  public var x:Int? = nil
  public var y:Int? = nil
/// :nodoc:
  public required init() {

  }
/// :nodoc:
  required public init?(map:Map) {
    //
  }
/// :nodoc:
  public func mapping(map:Map) {
    x <- map["x"]
    y <- map["y"]
  }
}

