//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//
import ObjectMapper

/**
 Provides base capabilities for TransactionRequests like SaleRequest, AuthRequest, PreAuthRequest, etc.
 */
public class TransactionRequest : NSObject, Mappable {
    /// The amount of the transaction. This includes amount, tax, service charges, etc. except the tip
    public var amount:Int = 0
    /// This prevents the Clover device from asking the POS for payment confirmations like duplicate and offline payment checks
    public var autoAcceptPaymentConfirmations:Bool?
    /// This prevents the Clover device form asking the POS to accept a signture and automatically accepts the signature
    public var autoAcceptSignature:Bool?
    /// Defines the methods the Clover device will accept payments.
    /// these constants can be OR'd together
    /// 1. MSR - CloverConnector.CARD_ENTRY_METHOD_MAG_STRIPE
    /// 2. CHIP - CloverConnector.CARD_ENTRY_METHOD_ICC_CONTACT
    /// 3. NFC - CloverConnector.CARD_ENTRY_METHOD_NFC_CONTACTLESS
    /// 4. Manual Card Entry - CloverConnector.CARD_ENTRY_METHOD_MANUAL
    public var cardEntryMethods:Int = 34567
    /**
     
     */
    public var cardNotPresent:Bool?
    /**
     will not check to see if the card was just used for a payment
     */
    public var disableDuplicateChecking:Bool?
    /**
     will disable printing and cause callbacks if "Print" is selected on the device.
     see: ICloverConnectorListener.onPrint* methods
    */
    public var disablePrinting:Bool?
    /**
     will skip the receipt screen and will flow as if "No Receipt" was selected
    */
    public var disableReceiptSelection:Bool?
    /**
     by default, the payment flow will restart if a transaction fails. This flag prevents
     the payment flow from restarting and returns the cancel flow
     */
    public var disableRestartTransactionOnFail:Bool?
    /**
     An id assigned by the POS that can be used to track a payment through the Clover
     system.
     */
    public var externalId:String
    /**
     An override for the merchant configuration for the threshold to require a signature
     */
    public var signatureThreshold:Int?
    /**
     TODO:
     */
    /// :nodoc:
    public var signatureEntryLocation:CLVModels.Payments.DataEntryLocation?
    /// :nodoc:
    public var type:TransactionType {
        get {
            return TransactionType.PAYMENT
        } set {
            // do nothing
        }
    }
    /**
     a VaultedCard that has been acquired from a vaultCard call.
    */
    public var vaultedCard:CLVModels.Payments.VaultedCard?
    
    
    
    
    
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    /// :nodoc:
    public required init?(map:Map) {
        self.externalId=""
        super.init()
    }

    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    /// :nodoc:
    public func mapping(map:Map) {
        amount <- map["amount"]
        autoAcceptPaymentConfirmations <- map["autoAcceptPaymentConfirmations"]
        autoAcceptSignature <- map["autoAcceptSignature"]
        cardEntryMethods <- map["cardEntryMethods"]
        cardNotPresent <- map["cardNotPresent"]
        disableDuplicateChecking <- map["disableDuplicateChecking"]
        disablePrinting <- map["disablePrinting"]
        disableReceiptSelection <- map["disableReceiptSelection"]
        disableRestartTransactionOnFail <- map["disableRestartTransactionOnFail"]
        externalId <- map["externalId"]
        signatureThreshold <- map["signatureThreshold"]
        type <- map["type"]
        vaultedCard <- map["vaultedCard"]
    }

    
    public init(amount:Int, externalId:String) {
//        self.type = transactionType
        self.amount = amount
        self.externalId = externalId
    }
    
    
}
