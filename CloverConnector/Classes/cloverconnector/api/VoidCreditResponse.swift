//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


/// :nodoc:
public class VoidCreditResponse:Mappable {

  /*
  * Identifier for the request
   */
  var requestId:String? = nil 
  var status:ResultStatus? = nil 
  /*
  * The credit that was voided
   */
  var credit:CLVModels.Payments.Credit? = nil 

  public required init() {

  }

  required public init?(map:Map) {
  }

  public func mapping(map:Map) {
  requestId <- map["requestId"]

  status <- map["status"]

  credit <- map["credit"]

  }
}

