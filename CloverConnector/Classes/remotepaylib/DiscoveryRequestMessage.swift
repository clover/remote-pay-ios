//
//  DiscoveryRequestMessage.swift
//  Pods
//
//
//
import Foundation
import ObjectMapper


/*
 * The message sent to the clover device upon connection
 */
public class DiscoveryRequestMessage:Message {

  /*
  * Identifier for the request
   */
  var requestId:String? = nil 

  public required init() {
    super.init(method: .DISCOVERY_REQUEST)
  }

  required public init?(map:Map) {
    super.init(method: .DISCOVERY_REQUEST)
  }

  public override func mapping(map:Map) {
    super.mapping(map: map)
    requestId <- map["requestId"]
  }

}
