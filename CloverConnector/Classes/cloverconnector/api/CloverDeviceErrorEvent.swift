//
//  ConfigErrorMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

@objc
public class CloverDeviceErrorEvent : NSObject {

    
    public private(set) var errorType:CloverDeviceErrorType
    public private(set) var code:Int;
    public private(set) var message:String
    
    public init(errorType:CloverDeviceErrorType, code:Int, message:String) {
        self.errorType = errorType
        self.code = code
        self.message = message
        super.init()
    }
}

public enum CloverDeviceErrorType:String
{
    case COMMUNICATION_ERROR = "COMMUNICATION_ERROR"
    case VALIDATION_ERROR = "VALIDATION_ERROR"
    case EXCEPTION = "EXCEPTION"
}
