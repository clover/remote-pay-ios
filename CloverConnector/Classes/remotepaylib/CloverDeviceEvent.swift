//
//  CloverDeviceEvent.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class CloverDeviceEvent:NSObject, Mappable {

    public enum DeviceEventState:String {
        // payment flow
        case START = "START"
        case FAILED = "FAILED"
        case FATAL = "FATAL"
        case TRY_AGAIN = "TRY_AGAIN"
        case INPUT_ERROR = "INPUT_ERROR"
        case PIN_BYPASS_CONFIRM = "PIN_BYPASS_CONFIRM"
        case CANCELED = "CANCELED"
        case TIMED_OUT = "TIMED_OUT"
        case DECLINED = "DECLINED"
        case VOIDED = "VOIDED"
        case CONFIGURING = "CONFIGURING"
        case PROCESSING = "PROCESSING"
        case REMOVE_CARD = "REMOVE_CARD"
        case PROCESSING_GO_ONLINE = "PROCESSING_GO_ONLINE"
        case PROCESSING_CREDIT = "PROCESSING_CREDIT"
        case PROCESSING_SWIPE = "PROCESSING_SWIPE"
        case SELECT_APPLICATION = "SELECT_APPLICATION"
        case PIN_PAD = "PIN_PAD"
        case MANUAL_CARD_NUMBER = "MANUAL_CARD_NUMBER"
        case MANUAL_CARD_CVV = "MANUAL_CARD_CVV"
        case MANUAL_CARD_CVV_UNREADABLE = "MANUAL_CARD_CVV_UNREADABLE"
        case MANUAL_CARD_EXPIRATION = "MANUAL_CARD_EXPIRATION"
        case SELECT_ACCOUNT = "SELECT_ACCOUNT"
        case CASHBACK_CONFIRM = "CASHBACK_CONFIRM"
        case CASHBACK_SELECT = "CASHBACK_SELECT"
        case CONTACTLESS_TAP_REQUIRED = "CONTACTLESS_TAP_REQUIRED"
        case VOICE_REFERRAL_RESULT = "VOICE_REFERRAL_RESULT"
        case CONFIRM_PARTIAL_AUTH = "CONFIRM_PARTIAL_AUTH"
        case PACKET_EXCEPTION = "PACKET_EXCEPTION"
        case CONFIRM_DUPLICATE_CHECK = "CONFIRM_DUPLICATE_CHECK"

        // verify CVM flow
        case VERIFY_SIGNATURE_ON_PAPER = "VERIFY_SIGNATURE_ON_PAPER"
        case VERIFY_SIGNATURE_ON_PAPER_CONFIRM_VOID = "VERIFY_SIGNATURE_ON_PAPER_CONFIRM_VOID"
        case VERIFY_SIGNATURE_ON_SCREEN = "VERIFY_SIGNATURE_ON_SCREEN"
        case VERIFY_SIGNATURE_ON_SCREEN_CONFIRM_VOID = "VERIFY_SIGNATURE_ON_SCREEN_CONFIRM_VOID"
        case ADD_SIGNATURE = "ADD_SIGNATURE"
        case SIGNATURE_ON_SCREEN_FALLBACK = "SIGNATURE_ON_SCREEN_FALLBACK"
        case RETURN_TO_MERCHANT = "RETURN_TO_MERCHANT"
        case SIGNATURE_REJECT = "SIGNATURE_REJECT"
        case ADD_SIGNATURE_CANCEL_CONFIRM = "ADD_SIGNATURE_CANCEL_CONFIRM"
        
        // add tip flow
        case ADD_TIP = "ADD_TIP"
        
        // receipt options flow
        case RECEIPT_OPTIONS = "RECEIPT_OPTIONS"
        
        // tender handling flow
        case HANDLE_TENDER = "HANDLE_TENDER"
        
        // starting custom activity, called from RTKA
        case STARTING_CUSTOM_ACTIVITY = "STARTING_CUSTOM_ACTIVITY"
    }
    
    public var eventState:DeviceEventState?
    public var code:Int?
    public var message:String?
    public var inputOptions:[InputOption]?

    public override required init() {
        super.init()
    }
    
    required public init?(map:Map) {
        super.init()
    }
    
    public init(eventState:DeviceEventState?, message:String?, inputOptions:[InputOption]? = nil) {
        self.eventState = eventState
        self.message = message
        self.inputOptions = inputOptions
        super.init()
    }
    
    public func mapping(map:Map) {
        eventState <- map["eventState"]
        
        code <- map["code"]
        
        message <- map["message"]
        
        inputOptions <- map["inputOptions"]
        
    }
}
