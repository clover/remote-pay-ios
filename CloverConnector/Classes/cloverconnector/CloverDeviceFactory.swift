//
//  CloverDeviceFactory.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

class CloverDeviceFactory {
    
    /// Factory to create an instance of a CloverDevice
    ///
    /// - Parameter config: Object that conveys the required information used by the device
    /// - Returns: Initialized instance of the CloverDevice
    class func get(_ config:CloverDeviceConfiguration) -> CloverDevice?{
        return DefaultCloverDevice(config: config);
    }
}
