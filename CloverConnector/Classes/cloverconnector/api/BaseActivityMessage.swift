//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

/**
 Base message used for exchanging messages between the POS and a Custom Activity
 */
public class BaseActivityMessage:NSObject {
    /**
     - Parameter action: the action of the custom activity
     - Parameter payload: the string payload to send to the custom activity
     */
    public init(action a:String, payload p:String? = nil) {
        self.action = a
        self.payload = p
    }
    public var action:String = ""
    public var payload:String?
}
