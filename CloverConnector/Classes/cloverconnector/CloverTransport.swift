//
//  CloverTransport.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
//import CloverSDKRemotepay

public class CloverTransport : NSObject {
    var observers = [CloverTransportObserver]()
    var ready:Bool = false
    var lastDiscoveryResponseMessage:DiscoveryResponseMessage? = nil
    
    public func initialize() {
        // needs to override in subclass
        fatalError("Must override")
    }
    
    func onDeviceConnected() {
        for obs in observers {
            obs.onDeviceConnected(self)
        }
    }
    
    func onDeviceReady(_ drm:DiscoveryResponseMessage) {
        ready = true
        for obs in observers {
            obs.onDeviceReady(self)
        }
    }
    
    func onDeviceDisconnected() {
        ready = false
        for obs in observers {
            obs.onDeviceDisconnected(self)
        }
    }
    
    /// <summary>
    /// Should be called by subclasses when a message is received.
    /// </summary>
    /// <param name="message"></param>
    func onMessage(_ message:String) {
        for obs in observers {
            obs.onMessage(message)
        }
    }
    
    func subscribe(_ observer:CloverTransportObserver) {
        // to notify if the device has already reported as ready
        if (ready) {
            for obs in observers {
                obs.onDeviceReady(self)
            }
        }
        observers.append(observer)
    }
    
    func dispose() {
        observers.removeAll()
    }
    
    func unsubscribe(_ observer:CloverTransportObserver) {
        guard let index = observers.index(where: {$0 === observer}) else { return }
        observers.remove(at: index)
    }
    
    // Implement this to send info
    @discardableResult
    func sendMessage(_ message:String) -> Int {
        return 0;
    }
    
    func getRemoteMessageVersion() -> Int {
        return 1;
    }
}
