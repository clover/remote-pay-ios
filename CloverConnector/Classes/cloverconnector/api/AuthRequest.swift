//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
   The request sent to the Auth method. 'amount' is the only field required.
 */
public class AuthRequest:TransactionRequest {
    /// if the Clover device can't communicate with the server, can the payment be taken offline and processed later
    public var allowOfflinePayment:Bool?
    /// if the Clover device can't communicate with the server, can the payment be taken offline without POS confirmatin
    public var approveOfflinePaymentWithoutPrompt:Bool?
    /// disable the cashback ui option for cards that support the cashback option
    public var disableCashback:Bool?
    /// records the tax amount for reporting purposes
    public var taxAmount:Int?
    /// The amount the precomputed tips on screen are based on
    public var tippableAmount:Int?
    /// Force a payment to be accepted without sending the payment to the server. The payment will be queued
    /// and processed as soon as the network and server become available
    public var forceOfflinePayment:Bool?
    
    /// :nodoc:
    public override var type:TransactionType {
        get {
            return TransactionType.PAYMENT
        }
        set {
            // do nothing
        }
    }
    
    /**
     * An Auth request requires an amount and an externalId that can be used to track the payment.
     */
    public required override init(amount:Int, externalId:String) {
        super.init(amount:amount, externalId:externalId);
    }
    
    /// :nodoc:
    public required init?(map:Map) {
        super.init(map: map)
    }
    
    /// :nodoc:
    public override func mapping(map:Map) {
        disableCashback <- map["disableCashback"]
        tippableAmount <- map["tippableAmount"]
        taxAmount <- map["taxAmount"]
        allowOfflinePayment <- map["allowOfflinePayment"]
        approveOfflinePaymentWithoutPrompt <- map["approveOfflinePaymentWithoutPrompt"]
        forceOfflinePayment <- map["forceOfflinePayment"]
    }

}

