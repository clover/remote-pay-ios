//
//  ExternalDeviceState.swift
//  Pods
//
//
//

public enum ExternalDeviceState:String {
    case UNKNOWN = "UNKNOWN"
    case IDLE = "IDLE"
    case BUSY = "BUSY"
    case WAITING_FOR_POS = "WAITING_FOR_POS"
    case WAITING_FOR_CUSTOMER = "WAITING_FOR_CUSTOMER"
}

public enum ExternalDeviceSubState:String {
    case UNKNOWN
    case CUSTOM_ACTIVITY
    case STARTING_PAYMENT_FLOW
    case PROCESSING_PAYMENT
    case PROCESSING_CARD_DATA
    case PROCESSING_CREDIT
    case VERIFY_SIGNATURE
    case TIP_SCREEN
    case RECEIPT_SCREEN
    case CONFIRM_PAYMENT
}

