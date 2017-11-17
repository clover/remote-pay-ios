//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 signature object used for payments
 */
public class Signature:Mappable {

  /**
  * A series of strokes representing a signature
   */
//  public var strokes:ListWrapper<Points>? = nil
    public var strokes:Array<Stroke>?
    /// width of signature area
    public var width:Int?
    /// height of signature area
    public var height:Int?

  public required init() {

  }
/// :nodoc:
  required public init?(map:Map) {
    
  }
/// :nodoc:
  public func mapping(map:Map) {
    strokes <- map["strokes"]
    width <- map["width"]
    height <- map["height"]
  }

/**
     A single path stroke of a signature
 */
    public class Stroke:Mappable {
        public var points:Array<Point>?
        /// :nodoc:
        required public init?(map:Map) {
            
        }
        /// :nodoc:
        public func mapping(map:Map) {
            points <- map["points"]
        }
    }
    
    
}

