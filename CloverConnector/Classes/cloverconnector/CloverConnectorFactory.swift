//
//  CloverConnectorFactory.swift
//  CloverConnector
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

public class CloverConnectorFactory {

    /// Factory to create an instance of the ICloverConnector
    ///
    /// - Parameter config: Object that conveys the required information used by the connector
    /// - Returns: Initialized instance conforming to the ICloverConnector
    public static func createICloverConnector(config: CloverDeviceConfiguration) -> ICloverConnector {
        return DefaultCloverConnectorV2(config: config)
    }
}
