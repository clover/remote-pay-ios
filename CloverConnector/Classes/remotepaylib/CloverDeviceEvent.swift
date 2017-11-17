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

    public enum DeviceEventState {
        // payment flow
        case start
        case failed
        case fatal
        case try_AGAIN
        case input_ERROR
        case pin_BYPASS_CONFIRM
        case canceled
        case timed_OUT
        case declined
        case voided
        case configurnig
        case processing
        case remove_CARD
        case processing_GO_ONLINE
        case processing_CREDIT
        case processing_SWIPE
        case select_APPLICATION
        case pin_PAD
        case manual_CARD_NUMBER
        case manual_CARD_CVV
        case manual_CARD_CVV_UNREADABLE
        case manual_CARD_EXPIRATION
        case select_ACCOUNT
        case cashback_CONFIRM
        case cashback_SELECT
        case contactless_TAP_REQUIRED
        case voice_REFERRAL_RESULT
        case confirm_PARTIAL_AUTH
        case packet_EXCEPTION
        case confirm_DUPLICATE_CHECK

        // verify CVM flow
        case verify_SIGNATURE_ON_PAPER
        case verify_SIGNATURE_ON_PAPER_CONFIRM_VOID
        case verify_SIGNATURE_ON_SCREEN
        case verify_SIGNATURE_ON_SCREEN_CONFIRM_VOID
        case add_SIGNATURE
        case signature_ON_SCREEN_FALLBACK
        case return_TO_MERCHANT
        case signature_REJECT
        case add_SIGNATURE_CANCEL_CONFIRM

        // add tip flow
        case add_TIP

        // receipt options flow
        case receipt_OPTIONS

        // tender handling flow
        case handle_TENDER
    }
    
//    public var eventState:DeviceEventState?
    public var eventState:String?
    public var code:Int?
    public var message:String?
    public var inputOptions:[InputOption]?

    public override required init() {
        super.init()
    }
    
    required public init?(map:Map) {
        super.init()
    }
    
    public init(eventState:String?, message:String?, inputOptions:[InputOption]? = nil) {
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
