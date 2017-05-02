//
//  CloverTransport.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDKRemotepay

@objc
public class CloverTransport : NSObject {
    var observers:NSMutableArray = NSMutableArray()
    var ready:Bool = false
    var lastDiscoveryResponseMessage:DiscoveryResponseMessage? = nil
    

    
    func onDeviceConnected() {
        for obs in observers {
            (obs as! CloverTransportObserver).onDeviceConnected(self)
        }
    }
    
    func onDeviceReady(_ drm:DiscoveryResponseMessage) {
        ready = true
        for obs in observers {
            (obs as! CloverTransportObserver).onDeviceReady(self)
        }
    }
    
    func onDeviceDisconnected() {
        ready = false
        for obs in observers {
            (obs as! CloverTransportObserver).onDeviceDisconnected(self)
        }
    }
    
    /// <summary>
    /// Should be called by subclasses when a message is received.
    /// </summary>
    /// <param name="message"></param>
    func onMessage(_ message:String) {
        for obs in observers {
            (obs as! CloverTransportObserver).onMessage(message)
        }
    }
    
    func subscribe(_ observer:CloverTransportObserver) {
        // to notify if the device has already reported as ready
        if (ready) {
            for obs in observers {
                (obs as! CloverTransportObserver).onDeviceReady(self)
            }
        }
        observers.addObject(observer)
    }
    
    func dispose() {
        observers.removeAllObjects()
    }
    
    func unsubscribe(_ observer:CloverTransportObserver) {
        observers.removeObject(observer)
    }
    
    // Implement this to send info
    func sendMessage(_ message:String) -> Int {
        return 0;
    }
}
