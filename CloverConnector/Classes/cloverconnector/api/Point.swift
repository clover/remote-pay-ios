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
  required public init?(_ map: Map) {
    //
  }
/// :nodoc:
  public func mapping(map:Map) {
    x <- map["x"]
    y <- map["y"]
  }

/*
  public required init(jsonObj:NSDictionary){
    super.init()

  x = jsonObj.valueForKey("x") as! Int?

  y = jsonObj.valueForKey("y") as! Int?
  }
*/

}

