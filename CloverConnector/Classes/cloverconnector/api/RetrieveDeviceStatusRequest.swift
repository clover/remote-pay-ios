//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

/**
 * The request sent to retrieve the current device status. 
 * if resend is true, the device will send its last request 
 * it is waiting for a response to such as
 * a signature or payment confirmation request
 */
public class RetrieveDeviceStatusRequest {
    /// indicate if the device should send that lastMessage if it is 
    /// waiting on a response
    public var sendLastMessage:Bool
    
    public init(sendLastMessage resend:Bool = false) {
        sendLastMessage = resend
    }
}
