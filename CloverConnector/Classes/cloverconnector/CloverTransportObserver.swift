//
//  CloverTransportObserver.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

protocol CloverTransportObserver : AnyObject{
    /// <summary>
    /// Device is there but not yet ready for use
    /// </summary>
    func onDeviceConnected(_ transport:CloverTransport)
    
    /// <summary>
    /// Device is there and ready for use
    /// </summary>
    func onDeviceReady(_ transport:CloverTransport)
    
    /// <summary>
    /// Device is not there anymore
    /// </summary>
    /// <param name="transport"></param>
    func onDeviceDisconnected(_ transport:CloverTransport)
    
    func onMessage(_ message:String)
}
