//
//  WebSocketCloverTransport.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import Starscream
import ObjectMapper

class WebSocketCloverTransport: CloverTransport {
    var socket:WebSocket?
    fileprivate var disposed = false
    fileprivate var reportDisconnectTimer:Timer? // if the client wants to be notified sooner than an actual timeout, this timer will do it
    fileprivate var disconnectTimer:Timer? // if a pong hadn't been received in this amount of time after a ping is sent, disconnect the websocket
    fileprivate var pingTimer:Timer? // how long after a pong will the next ping be sent
    fileprivate var endpoint:URL?
    
    fileprivate var processQueue = DispatchQueue(label: "com.clover.webSocketProcessingQueue", attributes: []) // serial dispatch queue to handle the processing in and out of data
    
    fileprivate var reportedDisconnect = false // keeps track if a deviceDisconnected message has been sent to the client, before it is actually disconnected so
                                        // if the pong is received before disconnect timeout, a deviceReady needs to be sent
    
    fileprivate var name:String = ""
    fileprivate var serialNumber = ""
    fileprivate var pairingAuthToken:String?
    fileprivate var pairingConfig:PairingDeviceConfiguration
    fileprivate var cloverDeviceConfig: CloverDeviceConfiguration?
    
    private var disableSSLValidation:Bool = false
    
    fileprivate var reconnectDelay = 2 // delay before attempting reconnect
    fileprivate var pingFrequency = 3 // period between pings in seconds
    fileprivate var pongTimeout = 20 // how long to wait for a pong before closing connection
    fileprivate var reportConnectionProblemAfter = 20 // if pong hasn't come back in this time, report as disconnected but still wait
    
    let df = DateFormatter()

    deinit {
        CCLog.d("deinit WebSocketCloverTransport")
    }

    
    init?(endpointURL:String, posName:String, serialNumber:String, cloverDeviceConfig:CloverDeviceConfiguration?, pairingAuthToken:String?, pairingDeviceConfiguration:PairingDeviceConfiguration, disableSSLCertificateValidation:Bool = false, pongTimeout pt:Int? = 15, pingFrequency pf:Int? = 3, reconnectDelay rd:Int? = 2, reportConnectionProblemAfter rt:Int? = 20) {

        df.dateFormat = "y-MM-dd H:m:ss.SSSS"
        
        self.pairingAuthToken = pairingAuthToken
        self.name = posName
        self.serialNumber = serialNumber
        self.cloverDeviceConfig = cloverDeviceConfig
        self.pairingConfig = pairingDeviceConfiguration
        self.disableSSLValidation = disableSSLCertificateValidation
        self.pingFrequency = pf ?? 5
        self.pongTimeout = pt ?? 15
        self.reportConnectionProblemAfter = rt ?? 15
        self.reconnectDelay = rd ?? 2
        
        super.init()
        
        if let endpoint = URL(string: endpointURL) {
            self.endpoint = endpoint
        } else {
            return nil
        }

    }
    
    override func initialize() {
        if let ep = self.endpoint {
            
            initialize(ep)
        } else {
            CCLog.w("endpoint is nil")
        }
    }
    
    func initialize(_ endpoint:URL) {
        self.endpoint = endpoint
        if let s = socket {
            if s.isConnected {
                return
            }
        }
        
        socket = WebSocket(url: endpoint)

        if let socket = socket {
            var pairing = false;
            socket.onConnect = { [weak self] in
                guard let processQueue = self?.processQueue else { return }
                processQueue.async(execute: { [weak self] in
                    CCLog.d("websocket is connected")
                    pairing = true
                    
                    self?.schedulePing()
                    self?.sendPairingRequest()
                })
            }
            socket.onDisconnect = { [weak self] error in
                guard let processQueue = self?.processQueue else { return }
                processQueue.async(execute: { [weak self] in
                    guard let self = self else {
                        CCLog.d("onDisconnect called on orphaned socket")
                        return
                    }
                    
                    if let error = error {
                        CCLog.d("websocket is disconnected: " + error.localizedDescription)
                        
                        for obs in self.observers {
                            obs.onDeviceError(.CONNECTION_ERROR, int: (error as NSError).code, cause: error, message: error.localizedDescription)
                        }
                    } else {
                        CCLog.d("websocket is disconnected")
                    }
                    
                    for obs in self.observers {
                        obs.onDeviceDisconnected(self)
                    }
                    
                    self.disconnectTimer?.invalidate()
                    self.reportDisconnectTimer?.invalidate()
                    
                    self.socket = nil
                    
                    if self.disposed {
                        return
                    }
                    
                    let delayTime = DispatchTime.now() + Double(Int64(Double(self.reconnectDelay) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).asyncAfter(deadline: delayTime, execute: {
                        self.initialize(endpoint)
                    })
                })
            }
            
            socket.onText = { [weak self] (text: String) in
                guard let processQueue = self?.processQueue else { return }
                processQueue.async(execute: { [weak self] in
                    guard let self = self else {
                        CCLog.d("onText called on orphaned socket")
                        return
                    }
                    
                    CCLog.d("websocket onText: " + text)
                    self.resetPong()
                    if (pairing) {
                        let parser:Mapper<PairingResponseMessage> = Mapper<PairingResponseMessage>()
                        let remoteMessage = parser.map(JSONString: text)
                        if(remoteMessage?.method == PairingCode.PAIRING_CODE && remoteMessage?.payload != nil) {
                            if let pcm:PairingCodeMessage = Mapper<PairingCodeMessage>().map(JSONString: remoteMessage!.payload!), let code = pcm.pairingCode {
                                CCLog.d("Got pairing code: " + code)
                                self.pairingConfig.onPairingCode(code)
                            } else {
                                CCLog.w("Error getting pairing code from: " + text)
                            }
                            
                        } else if (remoteMessage?.method == PairingCode.PAIRING_RESPONSE && remoteMessage?.payload != nil) {
                            if let pr:PairingResponse = Mapper<PairingResponse>().map(JSONString: remoteMessage!.payload!), let authToken = pr.authenticationToken {
                                if pr.pairingState == PairingCode.INITIAL || pr.pairingState == PairingCode.PAIRED {
                                    pairing = false;
                                    self.pairingAuthToken = authToken
                                    CCLog.d("pairing successful " + authToken)
                                    self.pairingConfig.onPairingSuccess(authToken)
                                    
                                    for obs in self.observers {
                                        obs.onDeviceReady(self)
                                    }
                                } else if pr.pairingState == PairingCode.FAILED {
                                    pairing = true
                                    CCLog.d("pairing failed")
                                    self.pairingAuthToken = nil
                                    //self.sendPairingRequest() // fail causes a disconnect, so this is taken care of in reconnect
                                }
                            }
                        } else {
                            if(remoteMessage?.method != "ACK" && remoteMessage?.method != "UI_STATE") {
                                CCLog.w("Error parsing message: " + text)
                            } else {
                                // we expect ACK and UI_STATE messages while pairing
                            }
                        }
                    } else {
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                            for obs in self.observers {
                                obs.onMessage(text)
                            }
                        }
                    }
                })
            }
            
            socket.onData = { [weak self] (data: Data) in
                guard let processQueue = self?.processQueue else { return }
                processQueue.async(execute: { 
                    CCLog.d("got some data: " + String(describing: data)) // don't expect this
                })
            }
            socket.onPong = { [weak self] (Void) in
                guard let processQueue = self?.processQueue else { return }
                processQueue.async(execute: { [weak self] in

//                Log.d(". " + self.df.stringFromDate(NSDate()))
                    self?.resetPong()
                })
            }
            // This only works in newer versions of Starscream
            socket.disableSSLCertValidation = disableSSLValidation
            if(disableSSLValidation) {
                CCLog.d("SSL Validation is turned off!")
            }
            CCLog.d("trying to connect")
            socket.connect(pongTimeout)
        }
    }

    
    func sendPairingRequest() {
        processQueue.async(execute: { [weak self] in
            guard let self = self else { return }

            let pairingRequest = PairingRequest(name: self.name, serialNumber: self.serialNumber, token: self.pairingAuthToken, remoteApplicationID: self.cloverDeviceConfig?.remoteApplicationID, remoteSourceSDK: self.cloverDeviceConfig?.remoteSourceSDK)
            let pairingRequestMessage = PairingRequestMessage(request: pairingRequest)
            pairingRequestMessage.method = PairingCode.PAIRING_REQUEST
            if let pairingRequestString = Mapper().toJSONString(pairingRequestMessage)
            {
                self.sendMessage(pairingRequestString)
            } else {
                CCLog.d("Error send pairing request!")
            }
        })
    }
    
    fileprivate func resetPong() {
        processQueue.async(execute: { [weak self] in
            guard let self = self else { return }
            self.disconnectTimer?.invalidate()
            self.reportDisconnectTimer?.invalidate()
            if self.reportedDisconnect {
                DispatchQueue.main.async {
                    for obs in self.observers {
                        obs.onDeviceReady(self)
                    }
                }
            }
            self.reportedDisconnect = false
            self.schedulePing()
        })
    }
    
    fileprivate func schedulePing() {
        processQueue.async(execute: { [weak self] in
            guard let self = self else { return }
            self.reportedDisconnect = false
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.pingTimer?.invalidate()
                self.pingTimer = Timer.scheduledTimer(timeInterval: Double(self.pingFrequency), target: self, selector: #selector(self.sendPing), userInfo: nil, repeats: false)
            }
        })
    }
    @objc fileprivate func sendPing() {
        processQueue.async(execute: { [weak self] in
            guard let self = self else { return }
            if let socket = self.socket {
                self.scheduleDisconnect()
//                Log.d("sending PING " + self.df.stringFromDate(NSDate()))
                socket.write(ping: Data())
            }
        })
    }
    
    fileprivate func scheduleDisconnect() {
        processQueue.async(execute: { [weak self] in
            guard let self = self else { return }

            // if requested to be told of disconnect before we force a disconnect
            if self.reportConnectionProblemAfter < self.pongTimeout {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.reportDisconnectTimer?.invalidate()
                    self.reportDisconnectTimer = Timer.scheduledTimer(timeInterval: Double(self.reportConnectionProblemAfter), target: self, selector: #selector(self.reportDisconnect), userInfo: nil, repeats: false)
                }
            }
        
            self.disconnectTimer?.invalidate()
            self.disconnectTimer = Timer.scheduledTimer(timeInterval: Double(self.pongTimeout), target: self, selector: #selector(self.disconnectMissedPong), userInfo: nil, repeats: false)
        })
    }
    @objc fileprivate func reportDisconnect() {
        processQueue.async(execute: { [weak self] in
            guard let self = self else { return }
            self.reportedDisconnect = true
            DispatchQueue.main.async {
                for obs in self.observers {
                    obs.onDeviceConnected(self)
                }
            }
        })
    }
    @objc fileprivate func disconnectMissedPong() {
        processQueue.async(execute: { [weak self] in
            guard let self = self else { return }

            if let ws = self.socket,
                let _ = self.endpoint {
                CCLog.d("forcing disconnect " + self.df.string(from: Date()))
                ws.disconnect(forceTimeout: 0)
            } else {
                self.dispose()
                // should we initialize here? how do we get in this state without messing up the state of the Transport?
            }
        })
    }
    
    public override func dispose() {
        super.dispose()
        disposed = true
        socket?.disconnect()
        socket = nil
        disconnectTimer?.invalidate()
        disconnectTimer = nil
        reportDisconnectTimer?.invalidate()
        reportDisconnectTimer = nil
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    @discardableResult
    override func sendMessage(_ message: String) -> Int {
        CCLog.d("Sending raw message: " + message)
        if let socket = socket {
            socket.write(string: message)
        }
        return 0
    }
    
    func reconnect() {
        
    }

}

extension WebSocket {
    public func connect(_ timeoutInSec: Int) {
        connect()
        let delayTime = DispatchTime.now() + Double(Int64(Double(timeoutInSec) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).asyncAfter(deadline: delayTime, execute: {
            if !self.isConnected {
                self.disconnect(forceTimeout: 0)
            }
        })
    }
}
