//
//  RetrieveDeviceStatusRequest.swift
//  Pods
//
//
//

public class RetrieveDeviceStatusRequest {
    public var sendLastMessage:Bool
    
    public init(sendLastMessage resend:Bool = false) {
        sendLastMessage = resend
    }
}
