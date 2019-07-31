//
//  WebSocketDeviceConfiguration.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public class WebSocketDeviceConfiguration : NSObject, CloverDeviceConfiguration {
    var endpoint:String
    public var remoteApplicationID:String
    public var posName:String
    public var posSerialNumber:String
    public var pairingAuthToken:String?
    fileprivate var pairingConfig:PairingDeviceConfiguration
    public var disableSSLValidation:Bool = false
    /// How often a ping is sent to the device server
    public var pingFrequency:Int?
    /// How long to wait for a pong, before disconnecting
    public var pongTimeout:Int?
    /// How long to wait after a failed connection to retry
    public var reconnectTimer:Int?
    /// How long to wait for a pong, before reporting a disconnect.
    /// Set this value less than pongTimeout, and it will report a disconnect before closing the connection
    /// Set this value greater than pongTimeout, and the disconnect will be reported after pongTimeout
    public var reportConnectionProblemTimeout:Int?

    public var maxCharInMessage:Int = 50000
    
    public private(set) var remoteSourceSDK:String = "com.cloverconnector.ios.ws"
    
    deinit {
        CCLog.d("deinit WebSocketDeviceConfiguration")
    }
    
    public init(endpoint:String, remoteApplicationID:String, posName:String, posSerial:String, pairingAuthToken:String?, pairingDeviceConfiguration:PairingDeviceConfiguration) {
        self.endpoint = endpoint
        self.remoteApplicationID = remoteApplicationID
        self.posName = posName
        self.posSerialNumber = posSerial
        self.pairingAuthToken = pairingAuthToken
        self.pairingConfig = pairingDeviceConfiguration
        
        if let version = Bundle.allFrameworks.filter({$0.bundleIdentifier != nil && $0.bundleIdentifier!.hasSuffix("CloverConnector")}).first?.infoDictionary?["CFBundleShortVersionString"] {
            remoteSourceSDK = "com.cloverconnector.ios.ws:\(version)"
        }
    }
    
    public func getTransport() -> CloverTransport? {
        let transport = WebSocketCloverTransport(endpointURL: endpoint, posName: posName, serialNumber: posSerialNumber, cloverDeviceConfig: self, pairingAuthToken: pairingAuthToken, pairingDeviceConfiguration: pairingConfig, disableSSLCertificateValidation: disableSSLValidation, pongTimeout: pongTimeout, pingFrequency: self.pingFrequency, reconnectDelay: reconnectTimer, reportConnectionProblemAfter: reportConnectionProblemTimeout);
        return transport
    }
    
    public func getCloverDeviceTypeName() -> String {
        return ""
    }
    
    public func getMessagePackageName() -> String {
        return "com.clover.remote_protocol_broadcast.app"
    }
    
    public func getName() -> String {
        return "Secure WebSocket Transport"
    }
    
    public func getMaxMessageCharacters() -> Int {
        return maxCharInMessage
    }
    
    /*
    private URI uri = null;
    /**
    * ping heartbeat interval in milliseconds
    */
    private long heartbeatInterval = 1000L;
    
    /**
    * delay before attempting a reconnect in milliseconds, so after a disconnect, the client will
    * try to establish a connection every <i>reconnectDelay</i> milliseconds
    */
    private long reconnectDelay = 3000L;
    
    /**
    * the number of missed pong response periods before a reconnect is executed.
    * Effectively, it will timeout after pingRetryCountBeforeReconnect * heartbeatInterval
    */
    private int pingRetryCountBeforeReconnect = 4;
    
    public WebSocketCloverDeviceConfiguration(URI endpoint) {
    uri = endpoint;
    }
    
    public WebSocketCloverDeviceConfiguration(URI endpoint, long heartbeatInterval, long reconnectDelay) {
    this(endpoint);
    this.heartbeatInterval = Math.max(100, heartbeatInterval);
    this.reconnectDelay = Math.max(0, reconnectDelay);
    }
    
    public Long getHeartbeatInterval() {
    return heartbeatInterval;
    }
    
    public void setHeartbeatInterval(Long heartbeatInterval) {
    this.heartbeatInterval = heartbeatInterval;
    }
    
    public Long getReconnectDelay() {
    return reconnectDelay;
    }
    
    public void setReconnectDelay(Long reconnectDelay) {
    this.reconnectDelay = reconnectDelay;
    }
    
    public int getPingRetryCountBeforeReconnect() {
    return pingRetryCountBeforeReconnect;
    }
    
    public void setPingRetryCountBeforeReconnect(int pingRetryCountBeforeReconnect) {
    this.pingRetryCountBeforeReconnect = pingRetryCountBeforeReconnect;
    }
    
    @Override
    public String getCloverDeviceTypeName() {
    return DefaultCloverDevice.class.getCanonicalName();
    }
    
    @Override
    public String getMessagePackageName() {
    return "com.clover.remote.protocol.lan";
    }
    
    @Override
    public String getName() {
    return "Clover WebSocket Connector";
    }
    
    @Override
    public CloverTransport getCloverTransport() {
    return new WebSocketCloverTransport(uri, heartbeatInterval, reconnectDelay, pingRetryCountBeforeReconnect);
    }
*/
}
