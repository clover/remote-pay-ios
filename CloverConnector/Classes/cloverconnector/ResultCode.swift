//
//  ResultCode.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public enum ResultCode:String {
    case SUCCESS = "SUCCESS" // this means the call succeeded and was successfully queued or processed
    case FAIL = "FAIL" // this means it failed because of some value passed in, or it failed for an unknown reason
    case UNSUPPORTED = "UNSUPPORTED" // this means the capability will never work without a config changed
    case CANCEL = "CANCEL" // this means the call was canceled for some reason, but could work if re-submitted
    case ERROR = "ERROR" // an error was encountered that wasn't expected or handled appropriately
}
