//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//
import ObjectMapper

/**
 Provides base capabilities for TransactionRequests like SaleRequest, AuthRequest, etc.
 */
public class TransactionRequest : BaseTransactionRequest {
    /// This prevents the Clover device form asking the POS to accept a signture and automatically accepts the signature
    public var autoAcceptSignature:Bool?
    
    /// An override for the merchant configuration for the threshold to require a signature
    public var signatureThreshold:Int?
    /**
     TODO:
     */
    /// :nodoc:
    public var signatureEntryLocation:CLVModels.Payments.DataEntryLocation?
    
    public var tipSuggestions: [CLVModels.Merchant.TipSuggestion]?
    
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    /// :nodoc:
    public required init?(map:Map) {
        super.init(map: map)
        self.externalId=""
    }
    
    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    /// :nodoc:
    override public func mapping(map:Map) {
        super.mapping(map: map)
        
        autoAcceptSignature <- map["autoAcceptSignature"]
        signatureThreshold <- map["signatureThreshold"]
        signatureEntryLocation <- map["signatureEntryLocation"]
        tipSuggestions <- map["tipSuggestions"]
    }
    
    override public init(amount:Int, externalId:String) {
        super.init(amount: amount, externalId: externalId)
        self.amount = amount
        self.externalId = externalId
    }
}
