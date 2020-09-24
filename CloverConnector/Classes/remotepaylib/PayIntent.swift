//
//  PayIntent.swift
//  CloverSDKRemotepay
//
//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//


import Foundation
import ObjectMapper



public class PayIntent:Mappable {

    public fileprivate(set) var action:String?
    public fileprivate(set) var amount = 0
    public fileprivate(set) var tipAmount:Int?
    public fileprivate(set) var taxAmount:Int?
    public fileprivate(set) var orderId:String?
    public fileprivate(set) var paymentId:String?
    public fileprivate(set) var employeeId:String?
    public fileprivate(set) var transactionType:TransactionType?
    public fileprivate(set) var isDisableCashBack = false
    public fileprivate(set) var isTesting = false
    public fileprivate(set) var cardEntryMethods = 15
    public fileprivate(set) var voiceAuthCode:String?
    public fileprivate(set) var postalCode:String?
    public fileprivate(set) var streetAddress:String?
    public fileprivate(set) var isCardNotPresent:Bool?
    public fileprivate(set) var cardDataMessage:String?
    public fileprivate(set) var remotePrint:Bool?
    public fileprivate(set) var transactionNo:String?
    public fileprivate(set) var isForceSwipePinEntry:Bool?
    public fileprivate(set) var externalPaymentId:String?
    public fileprivate(set) var vaultedCard:CLVModels.Payments.VaultedCard?
    public fileprivate(set) var allowOfflinePayment:Bool?
    public fileprivate(set) var approveOfflinePaymentWithoutPrompt:Bool?
    public fileprivate(set) var requiresRemoteConfirmation:Bool?
    public fileprivate(set) var applicationTracking:CLVModels.Apps.AppTracking?
    public fileprivate(set) var allowPartialAuth = true
    public fileprivate(set) var transactionSettings:CLVModels.Payments.TransactionSettings?
    public fileprivate(set) var disableCreditSurcharge = false
    
    /// Extra pass-through data used by external systems.
    public fileprivate(set) var passThroughValues: [String: String]?

    public init(amount:Int, externalId:String) {
        self.amount = amount
        self.externalPaymentId = externalId
    }
  public required init() {
        self.amount = 0
  }

  public required init(map:Map){
    self.amount = 0
  }

    public func mapping(map:Map) {

        action <- map["action"]
        amount <- map["amount"]
        tipAmount <- map["tipAmount"]
        taxAmount <- map["taxAmount"]
        orderId <- map["orderId"]
        paymentId <- map["paymentId"]
        employeeId <- map["employeeId"]
        transactionType <- map["transactionType"]
        isDisableCashBack <- map["isDisableCashBack"]
        isTesting <- map["isTesting"]
        cardEntryMethods <- map["cardEntryMethods"]
        voiceAuthCode <- map["voiceAuthCode"]
        postalCode <- map["postalCode"]
        streetAddress <- map["streetAddress"]
        isCardNotPresent <- map["isCardNotPresent"]
        cardDataMessage <- map["cardDataMessage"]
        remotePrint <- map["remotePrint"]
        transactionNo <- map["transactionNo"]
        isForceSwipePinEntry <- map["isForceSwipePinEntry"]
        externalPaymentId <- map["externalPaymentId"]
        vaultedCard <- map["vaultedCard"]
        allowOfflinePayment <- map["allowOfflinePayment"]
        approveOfflinePaymentWithoutPrompt <- map["approveOfflinePaymentWithoutPrompt"]
        requiresRemoteConfirmation <- map["requiresRemoteConfirmation"]
        applicationTracking <- map["applicationTracking"]
        allowPartialAuth <- map["allowPartialAuth"]
        transactionSettings <- map["transactionSettings"]
        passThroughValues <- map["passThroughValues"]
        disableCreditSurcharge <- map["isDisableCreditSurcharge"]
    }


    public class Builder {
        public var action:String?
        public var amount:Int = 0
        public var tipAmount:Int?
        public var taxAmount:Int?
        public var orderId:String?
        public var paymentId:String? = nil
        public var employeeId:String?
        public var transactionType:TransactionType?
        public var isDisableCashBack = false
        public var isTesting = false
        public var cardEntryMethods:Int = 0
        public var voiceAuthCode:String?
        public var postalCode:String?
        public var streetAddress:String?
        public var isCardNotPresent = false
        public var cardDataMessage:String?
        public var remotePrint = false
        public var transactionNo:String?
        public var isForceSwipePinEntry:Bool = false
        public var externalPaymentId:String? = nil
        public var vaultedCard:CLVModels.Payments.VaultedCard?
        public var allowOfflinePayment:Bool?
        public var approveOfflinePaymentWithoutPrompt:Bool?
        public var requiresRemoteConfirmation:Bool?
        public var applicationTracking:CLVModels.Apps.AppTracking?
        public var allowPartialAuth = true
        public var transactionSettings:CLVModels.Payments.TransactionSettings?
        public var disableCreditSurcharge = false
        
        /// Extra pass-through data used by external systems.
        public var passThroughValues: [String: String]?

        /// Use for requesting a new payment from the Clover Device
        public init(amount:Int, externalId:String) {
            self.amount = amount
            self.externalPaymentId = externalId
        }
        /// Use for requesting to pay for an order using an existing payment (i.e. PreAuth Capture)
        public init(amount:Int, paymentId:String) {
            self.amount = amount
            self.paymentId = paymentId
        }

        public func build() -> PayIntent {
            let payIntent = PayIntent()
            payIntent.action = self.action
            payIntent.amount = self.amount
            payIntent.tipAmount = self.tipAmount
            payIntent.taxAmount = self.taxAmount
            payIntent.orderId = self.orderId
            payIntent.paymentId = self.paymentId
            payIntent.employeeId = self.employeeId
            payIntent.transactionType = self.transactionType
            payIntent.isDisableCashBack = self.isDisableCashBack
            payIntent.isTesting = self.isTesting
            payIntent.cardEntryMethods = self.cardEntryMethods
            payIntent.voiceAuthCode = self.voiceAuthCode
            payIntent.postalCode = self.postalCode
            payIntent.streetAddress = self.streetAddress
            payIntent.isCardNotPresent = self.isCardNotPresent
            payIntent.cardDataMessage = self.cardDataMessage
            payIntent.remotePrint = self.remotePrint
            payIntent.transactionNo = self.transactionNo
            payIntent.isForceSwipePinEntry = self.isForceSwipePinEntry
            payIntent.externalPaymentId = self.externalPaymentId
            payIntent.vaultedCard = self.vaultedCard
            payIntent.allowOfflinePayment = self.allowOfflinePayment
            payIntent.approveOfflinePaymentWithoutPrompt = self.approveOfflinePaymentWithoutPrompt
            payIntent.requiresRemoteConfirmation = self.requiresRemoteConfirmation
            payIntent.applicationTracking = self.applicationTracking
            payIntent.allowPartialAuth = self.allowPartialAuth
            payIntent.transactionSettings = self.transactionSettings
            payIntent.passThroughValues = self.passThroughValues
            
            //Apply the transaction settings value, if applicable, before reverting to the builder's default value
            if let disableCreditSurcharge = self.transactionSettings?.disableCreditSurcharge {
                payIntent.disableCreditSurcharge = disableCreditSurcharge
            } else {
                payIntent.disableCreditSurcharge = self.disableCreditSurcharge
            }

            return payIntent
        }
    }
}
