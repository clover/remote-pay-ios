//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 options for capturing a pre-auth
 */
public class CapturePreAuthRequest : NSObject, Mappable {

    public var version = 1
    
    /**
     * Total amount paid
     */
    public var amount:Int
    /**
     * Amount paid in tips
     */
    public var tipAmount:Int? = nil
    /**
     * Unique identifier
     */
    public var paymentId:String
    
    public var externalId:String? = nil
    public var tippableAmount:Int? = nil
    public var tipMode:CLVModels.Payments.TipMode? = nil
    public var autoAcceptsSignature:Bool? = nil
    public var disablePrinting:Bool? = nil
    public var signatureEntryLocation:CLVModels.Payments.DataEntryLocation? = nil
    public var disableReceiptSelection:Bool? = nil
    public var signatureThreshold:Int? = nil

    public required init(amount:Int, paymentId:String) {
        self.amount = amount
        self.paymentId = paymentId

    }

    /// :nodoc:
    public required init?(map:Map) {
        amount = 0
        paymentId = ""
        super.init()
    }

    /// :nodoc:
    public func mapping(map:Map) {
        version <- map["version"]
        amount <- map["amount"]
        tipAmount <- map["tipAmount"]
        paymentId <- map["paymentId"]
        externalId <- map["externalId"]
        tippableAmount <- map["tippableAmount"]
        tipMode <- map["tipMode"]
        autoAcceptsSignature <- map["autoAcceptsSignature"]
        disablePrinting <- map["disablePrinting"]
        signatureEntryLocation <- map["signatureEntryLocation"]
        disableReceiptSelection <- map["disableReceiptSelection"]
        signatureThreshold <- map["signatureThreshold"]
    }

}
