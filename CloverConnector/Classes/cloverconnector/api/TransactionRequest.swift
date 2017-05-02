//
//  TxRequest.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//
import ObjectMapper

@objc
public class TransactionRequest : NSObject, Mappable {
    
    public var amount:Int = 0
    public var autoAcceptPaymentConfirmations:Bool?
    public var autoAcceptSignature:Bool?
    public var cardEntryMethods:Int = 34567
    public var cardNotPresent:Bool?
    public var disableDuplicateChecking:Bool?
    public var disablePrinting:Bool?
    public var disableReceiptSelection:Bool?
    public var disableRestartTransactionOnFail:Bool?
    public var externalId:String
    public var signatureThreshold:Int?
    public var signatureEntryLocation:CLVModels.Payments.DataEntryLocation?
    public var type:TransactionType {
        get {
            return TransactionType.PAYMENT
        } set {
            // do nothing
        }
    }
    public var vaultedCard:CLVModels.Payments.VaultedCard?
    
    
    
    
    
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    public required init?(_ map: Map) {
        self.externalId=""
        super.init()
    }

    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    public func mapping(map: Map) {
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
