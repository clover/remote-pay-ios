//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


/**
 request information for a request initiated by the device
 for a transaction
 */
public class VerifySignatureRequest:NSObject, Mappable {

  /*
  * Identifier for the request
   */
  var requestId:String? = nil 
  /*
  * Payment that the signature is verifying for
   */
  public var payment:CLVModels.Payments.Payment? = nil
  public var signature:Signature? = nil

  public override required init() {
    super.init()
  }
/// :nodoc:
  required public init?(map:Map) {
    super.init()
  }
/// :nodoc:
  public func mapping(map:Map) {
    requestId <- map["requestId"]

    let paymentTransform = TransformOf<CLVModels.Payments.Payment, String>(fromJSON: { (value: String?) -> CLVModels.Payments.Payment? in
        
        if let val = value,
            let pi = Mapper<CLVModels.Payments.Payment>().map(JSONString: val) {
            return pi
        }
        return nil
        }, toJSON: { (obj: CLVModels.Payments.Payment?) -> String? in
            
            if let val = obj,
                let value = Mapper().toJSONString(val, prettyPrint:true) {
                return String(value)
            }
            return nil
    })
    
    payment <- (map["payment"], paymentTransform)
    
    signature <- map["signature"]
  }

}

