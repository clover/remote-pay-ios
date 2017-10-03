//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//


import Foundation

public class OpenCashDrawerRequest : NSObject {
    /// A description for why the drawer is being opened
    let reason: String
    
    /// The identifier of the cash drawer to be opened. If nil, will fall back to the default drawer.
    let deviceId: String?
    
    /// Create an object used to inform the Clover Connector's `openCashDrawer()` function of required/additional information when requesting the cash drawer be opened
    ///
    /// - Parameters:
    ///   - reason: String describing the reason to open the drawer
    ///   - deviceId: Identifier of the drawer to be opened, or nil
    public init(_ reason: String, deviceId: String?) {
        self.reason = reason
        self.deviceId = deviceId
    }
    
    fileprivate override init() { //marking as private to enforce object creation through another initializer
        self.reason = String()
        self.deviceId = nil
    }
}
