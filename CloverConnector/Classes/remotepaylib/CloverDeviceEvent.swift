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

    public enum DeviceEventState: String {
        // payment flow
        case START
        case FAILED
        case FATAL
        case TRY_AGAIN
        case INPUT_ERROR
        case PIN_BYPASS_CONFIRM
        case CANCELED
        case TIMED_OUT
        case DECLINED
        case VOIDED
        case CONFIGURING
        case PROCESSING
        case REMOVE_CARD
        case PROCESSING_GO_ONLINE
        case PROCESSING_CREDIT
        case PROCESSING_SWIPE
        case SELECT_APPLICATION
        case PIN_PAD
        case MANUAL_CARD_NUMBER
        case MANUAL_CARD_CVV
        case MANUAL_CARD_CVV_UNREADABLE
        case MANUAL_CARD_EXPIRATION
        case SELECT_ACCOUNT
        case CASHBACK_CONFIRM
        case CASHBACK_SELECT
        case CONTACTLESS_TAP_REQUIRED
        case VOICE_REFERRAL_RESULT
        case CONFIRM_PARTIAL_AUTH
        case PACKET_EXCEPTION
        case CONFIRM_DUPLICATE_CHECK

        // verify CVM flow
        case VERIFY_SIGNATURE_ON_PAPER
        case VERIFY_SIGNATURE_ON_PAPER_CONFIRM_VOID
        case VERIFY_SIGNATURE_ON_SCREEN
        case VERIFY_SIGNATURE_ON_SCREEN_CONFIRM_VOID
        case ADD_SIGNATURE
        case SIGNATURE_ON_SCREEN_FALLBACK
        case RETURN_TO_MERCHANT
        case SIGNATURE_REJECT
        case ADD_SIGNATURE_CANCEL_CONFIRM
        
        // Quick Pay
        case CONFIRM_AMOUNT
        case SENSORY_EXPERIENCE
        
        // add tip flow
        case ADD_TIP
        
        // receipt options flow
        case RECEIPT_OPTIONS
        
        // tender handling flow
        case HANDLE_TENDER
        
        // starting custom activity, called from RTKA
        case STARTING_CUSTOM_ACTIVITY
        case CUSTOM_ACTIVITY
        
        //Canada-specific
        case SELECT_WITHDRAW_FROM_ACCOUNT
        case VERIFY_SURCHARGES
        case VOID_CONFIRM
        
        //Catch-all
        case UNKNOWN
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
