/**
 * Autogenerated by Avro
 * 
 * DO NOT EDIT DIRECTLY
 */

import Foundation
import ObjectMapper




/*
Snapshot of a line item modifier at the time that the order was placed.
 */
public class DisplayModification:Mappable {

  public var id:String? = nil
  public var name:String? = nil
  public var amount:String? = nil

  public required init() {

  }

  required public init?(map:Map) {
  }

  public func mapping(map:Map) {
  id <- map["id"]

  name <- map["name"]

  amount <- map["amount"]

  }
}

