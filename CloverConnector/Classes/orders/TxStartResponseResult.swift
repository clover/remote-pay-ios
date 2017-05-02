//
//  TxStartResponseResult.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public enum TxStartResponseResult:String {
    case SUCCESS="SUCCESS"
    case ORDER_MODIFIED="ORDER_MODIFIED"
    case ORDER_LOAD="ORDER_LOAD"
    case FAIL="FAIL"
    case DUPLICATE="DUPLICATE"
}
