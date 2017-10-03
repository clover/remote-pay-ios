//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

/**
 generic message for unanticipated or unexpected errors
 */
public class CloverDeviceErrorEvent : NSObject {
    /**
     * general type of error
     * - COMMUNICATION_ERROR
     * - VALIDATION_ERROR
     * - EXCEPTION
     */
    public fileprivate(set) var errorType:CloverDeviceErrorType
    public fileprivate(set) var code:Int?
    public fileprivate(set) var cause:Error?
    public fileprivate(set) var message:String
    
    public init(errorType:CloverDeviceErrorType, code:Int?, cause:Error?, message:String) {
        self.errorType = errorType
        self.code = code
        self.cause = cause
        self.message = message
        super.init()
    }
}
/**
 general classification for CloverDeviceErrorEvent
 */
public enum CloverDeviceErrorType:String
{
    case COMMUNICATION_ERROR = "COMMUNICATION_ERROR"
    case VALIDATION_ERROR = "VALIDATION_ERROR"
    case EXCEPTION = "EXCEPTION"
    case CONNECTION_ERROR = "CONNECTION_ERROR"
}
