//
//  VoidReason.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation


public enum VoidReason:String {
    case USER_CANCEL = "USER_CANCEL"
    case TRANSPORT_ERROR = "TRANSPORT_ERROR"
    case REJECT_SIGNATURE = "REJECT_SIGNATURE"
    case REJECT_PARTIAL_AUTH = "REJECT_PARTIAL_AUTH"
    case NOT_APPROVED = "NOT_APPROVED"
    case FAILED = "FAILED"
    case AUTH_CLOSED_NEW_CARD = "AUTH_CLOSED_NEW_CARD"
    case DEVELOPER_PAY_PARTIAL_AUTH = "DEVELOPER_PAY_PARTIAL_AUTH"
    case REJECT_DUPLICATE = "REJECT_DUPLICATE"
}
