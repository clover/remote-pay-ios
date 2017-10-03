//
//  UiStateMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public enum UiState :String{
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
    case FORCE_ACCEPTANCE = "FORCE_ACCEPTANCE"
    case VERIFY_SIGNATURE_ON_PAPER = "VERIFY_SIGNATURE_ON_PAPER"
    case VERIFY_SIGNATURE_ON_PAPER_CONFIRM_VOID = "VERIFY_SIGNATURE_ON_PAPER_CONFIRM_VOID"
    case VERIFY_SIGNATURE_ON_SCREEN = "VERIFY_SIGNATURE_ON_SCREEN"
    case VERIFY_SIGNATURE_ON_SCREEN_CONFIRM_VOID = "VERIFY_SIGNATURE_ON_SCREEN_CONFIRM_VOID"
    case ADD_SIGNATURE = "ADD_SIGNATURE"
    case SIGNATURE_ON_SCREEN_FALLBACK = "SIGNATURE_ON_SCREEN_FALLBACK"
    case RETURN_TO_MERCHANT = "RETURN_TO_MERCHANT"
    case SIGNATURE_REJECT = "SIGNATURE_REJECT"
    case ADD_SIGNATURE_CANCEL_CONFIRM = "ADD_SIGNATURE_CANCEL_CONFIRM"
    case ADD_TIP = "ADD_TIP"
    case RECEIPT_OPTIONS = "RECEIPT_OPTIONS"
    case HANDLE_TENDER = "HANDLE_TENDER"
    case SELECT_LANGUAGE = "SELECT_LANGUAGE"
    case APPROVED = "APPROVED"
    case OFFLINE_PAYMENT_CONFIRM = "OFFLINE_PAYMENT_CONFIRM"
    
    public enum UiDirection:String {
        case ENTER = "ENTER"
        case EXIT = "EXIT"
    }
}


public class UiStateMessage : Message {
    

    
    public var uiState:UiState?
    public var uiText:String?
    public var uiDirection:UiState.UiDirection?
    public var inputOptions:[InputOption]?
    
    public init(uiState:UiState?, uiText:String?, uiDirection:UiState.UiDirection?, inputOptions:[InputOption]) {
        super.init(method: .UI_STATE);
        self.uiState = uiState;
        self.uiText = uiText;
        self.uiDirection = uiDirection;
        self.inputOptions = inputOptions;
    }
    
    public required init() {
        super.init(method: .UI_STATE)
    }
    required public init?(map:Map) {
        super.init(method: .UI_STATE)
    }
    public override func mapping(map:Map) {
        super.mapping(map: map)
        
        uiState <- (map["uiState"], Message.uiStateTransform)
        uiText <- map["uiText"]
        uiDirection <- (map["uiDirection"], Message.uiDirectionTransform)
        inputOptions <- map["inputOptions"]
    }
}
