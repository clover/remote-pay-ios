//
//  PairingDeviceConfiguration.swift
//  Pods
//
//  
//
//

import Foundation

@objc
public protocol PairingDeviceConfiguration {
    func onPairingCode(pairingCode:String)
    func onPairingSuccess(authToken:String)
}
