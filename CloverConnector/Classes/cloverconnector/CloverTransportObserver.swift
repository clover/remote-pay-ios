//
//  CloverTransportObserver.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

protocol CloverTransportObserver : AnyObject{

    /// Device is there but not yet ready for use
    ///
    /// - Parameter transport: The transport instance being referenced
    func onDeviceConnected(_ transport:CloverTransport)
    
    /// Device is there and ready for use
    ///
    /// - Parameter transport: The transport instance being referenced
    func onDeviceReady(_ transport:CloverTransport)
    
    /// Device is not there anymore
    ///
    /// - Parameter transport: The transport instance being referenced
    func onDeviceDisconnected(_ transport:CloverTransport)
    
    /// Device experienced an error on the transport
    ///
    /// - Parameters:
    ///   - errorType: Type of the CloverDeviceErrorType being thrown
    ///   - int: Code from the NSError experienced earlier in the flow
    ///   - message: LocalizedDescription from the NSError experienced earlier in the flow
    func onDeviceError(_ errorType:CloverDeviceErrorType, int:Int?, cause:Error?, message:String)
    
    func onMessage(_ message:String)
}
