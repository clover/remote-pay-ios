//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//
import ObjectMapper

/**
 options for a pre-authorization request
 */
public class PreAuthRequest:TransactionRequest {

    /// :nodoc:
    public override var type:TransactionType {
        get {
            return TransactionType.AUTH
        }
        set {
            // do nothing
        }
    }
    public override init(amount:Int, externalId:String) {
        super.init(amount:amount, externalId:externalId);
    }
    
    /// :nodoc:
    public required init?(map:Map) {
        super.init(map:map)
    }

}

