//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

/**
 * Contains configuration options for processing a sale.
 */
public class SaleRequest:TransactionRequest {
    /// if the Clover device can't communicate with the server, can the payment be taken offline and processed later
    public var allowOfflinePayment:Bool?
    /// if the Clover device can't communicate with the server, can the payment be taken offline without POS confirmatin
    public var approveOfflinePaymentWithoutPrompt:Bool?
    /// disable the cashback ui option for cards that support the cashback option
    public var disableCashback:Bool?
    /// disable tip selection on screen. The tipMode should be set to TIP_PROVIDED if true
    public var disableTipOnScreen:Bool?
    /// records the tax amount for reporting purposes
    public var taxAmount:Int?
    /// if tipMode is TIP_PROVIDED, this tip amount will be used for the payment. *Note:* This is in addition to the amount
    public var tipAmount:Int?
    /// determines the tip mode for the transaction.
    /// - TIP_PROVIDED -> use the tipAmount
    /// - ON_SCREEN_BEFORE_PAYMENT -> ask the customer to select the tip before charging the card
    /// - NO_TIP -> the tipAmount is set to 0 and the customer isn't prompted to select a tip
    public var tipMode:TipMode?
    /// The amount the precomputed tips on screen are based on
    public var tippableAmount:Int?
    /// Force a payment to be accepted without sending the payment to the server. The payment will be queued
    /// and processed as soon as the network and server become available
    public var forceOfflinePayment:Bool?
    
    /// :nodoc:
    override public var type:TransactionType {
        get {
            return TransactionType.PAYMENT
        }
        set {
            // do nothing
        }
    }
    
    /**
     * A Sale request requires an amount and an externalId that can be used to track the payment.
     */
    public override init(amount:Int, externalId:String) {
        super.init(amount:amount, externalId:externalId)
    }
    
    /// :nodoc:
    public required init?(map:Map) {
        super.init(map: map)
    }

    /// :nodoc:
    public override func mapping(map:Map) {
        tippableAmount <- map["tippableAmount"]
        tipAmount <- map["tipAmount"]
        taxAmount <- map["taxAmount"]
        disableCashback <- map["disableCashback"]
        disableTipOnScreen <- map["disableTipOnScreen"]
        allowOfflinePayment <- map["allowOfflinePayment"]
        approveOfflinePaymentWithoutPrompt <- map["approveOfflinePaymentWithoutPrompt"]
        tipMode <- map["tipMode"]
        forceOfflinePayment <- map["forceOfflinePayment"]
    }

    /**
     enum for indicating the mode for aquiring a tip
     */
    public enum TipMode:String {
        /// the tipAmount must not be null or negative
        case TIP_PROVIDED = "TIP_PROVIDED"
        /// the tip screen will display before taking the payment
        case ON_SCREEN_BEFORE_PAYMENT = "ON_SCREEN_BEFORE_PAYMENT"
        /// the tip is 0, and no tip screen is displayed
        case NO_TIP = "NO_TIP"
    }

}

