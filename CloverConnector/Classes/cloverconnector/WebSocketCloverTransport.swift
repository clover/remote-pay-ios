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
    
    private var disableSSLValidation:Bool = false
    
    fileprivate var reconnectDelay = 2 // delay before attempting reconnect
    fileprivate var pingFrequency = 3 // period between pings in seconds
    fileprivate var pongTimeout = 20 // how long to wait for a pong before closing connection
    fileprivate var reportConnectionProblemAfter = 20 // if pong hasn't come back in this time, report as disconnected but still wait
    
    let df = DateFormatter()

    deinit {
        debugPrint("deinit WebSocketCloverTransport")
    }

    
    init?(endpointURL: String, posName:String, serialNumber:String, pairingAuthToken: String?, pairingDeviceConfiguration:PairingDeviceConfiguration, disableSSLCertificateValidation:Bool = false, pongTimeout pt:Int? = 15, pingFrequency pf:Int? = 3, reconnectDelay rd:Int? = 2, reportConnectionProblemAfter rt:Int? = 20) {

        df.dateFormat = "y-MM-dd H:m:ss.SSSS"
        
        self.pairingAuthToken = pairingAuthToken
        self.name = posName
        self.serialNumber = serialNumber
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
            debugPrint("endpoint is nil", __stderrp)
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
                    debugPrint("websocket is connected")
                    pairing = true
                    
                    self?.schedulePing()
                    self?.sendPairingRequest()
                })
            }
            socket.onDisconnect = { [weak self] error in
                guard let processQueue = self?.processQueue else { return }
                processQueue.async(execute: { [weak self] in
                    guard let strongSelf = self else {
                        debugPrint("onDisconnect called on orphaned socket")
                        return
                    }
                    
                    if let error = error {
                        debugPrint("websocket is disconnected: " + error.localizedDescription)
                        
                        for obs in strongSelf.observers {
                            obs.onDeviceError(.CONNECTION_ERROR, int: error.code, cause: error, message: error.localizedDescription)
                        }
                    } else {
                        debugPrint("websocket is disconnected")
                    }
                    
                    for obs in strongSelf.observers {
                        obs.onDeviceDisconnected(strongSelf)
                    }
                    
                    strongSelf.disconnectTimer?.invalidate()
                    strongSelf.reportDisconnectTimer?.invalidate()
                    
                    strongSelf.socket = nil
                    
                    if strongSelf.disposed {
                        return
                    }
                    
                    let delayTime = DispatchTime.now() + Double(Int64(Double(strongSelf.reconnectDelay) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).asyncAfter(deadline: delayTime, execute: {
                        strongSelf.initialize(endpoint)
                    })
                })
            }
            
            socket.onText = { [weak self] (text: String) in
                guard let processQueue = self?.processQueue else { return }
                processQueue.async(execute: { [weak self] in
                    guard let strongSelf = self else {
                        debugPrint("onText called on orphaned socket")
                        return
                    }
                    
                    debugPrint("websocket onText: " + text)
                    strongSelf.resetPong()
                    if (pairing) {
                        let parser:Mapper<PairingResponseMessage> = Mapper<PairingResponseMessage>()
                        let remoteMessage = parser.map(JSONString: text)
                        if(remoteMessage?.method == PairingCode.PAIRING_CODE && remoteMessage?.payload != nil) {
                            if let pcm:PairingCodeMessage = Mapper<PairingCodeMessage>().map(JSONString: remoteMessage!.payload!), let code = pcm.pairingCode {
                                debugPrint("Got pairing code: " + code)
                                strongSelf.pairingConfig.onPairingCode(code)
                            } else {
                                debugPrint("Error getting pairing code from: " + text, stderr)
                            }
                            
                        } else if (remoteMessage?.method == PairingCode.PAIRING_RESPONSE && remoteMessage?.payload != nil) {
                            if let pr:PairingResponse = Mapper<PairingResponse>().map(JSONString: remoteMessage!.payload!), let authToken = pr.authenticationToken {
                                if pr.pairingState == PairingCode.INITIAL || pr.pairingState == PairingCode.PAIRED {
                                    pairing = false;
                                    strongSelf.pairingAuthToken = authToken
                                    debugPrint("pairing successful " + authToken)
                                    strongSelf.pairingConfig.onPairingSuccess(authToken)
                                    
                                    for obs in strongSelf.observers {
                                        obs.onDeviceReady(strongSelf)
                                    }
                                } else if pr.pairingState == PairingCode.FAILED {
                                    pairing = true
                                    debugPrint("pairing failed")
                                    strongSelf.pairingAuthToken = nil
                                    //self.sendPairingRequest() // fail causes a disconnect, so this is taken care of in reconnect
                                }
                            }
                        } else {
                            if(remoteMessage?.method != "ACK" && remoteMessage?.method != "UI_STATE") {
                                debugPrint("Error parsing message: " + text, stderr)
                            } else {
                                // we expect ACK and UI_STATE messages while pairing
                            }
                        }
                    } else {
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                            for obs in strongSelf.observers {
                                obs.onMessage(text)
                            }
                        }
                    }
                })
            }
            
            socket.onData = { [weak self] (data: Data) in
                guard let processQueue = self?.processQueue else { return }
                processQueue.async(execute: { 
                    debugPrint("got some data: " + String(describing: data)) // don't expect this
                })
            }
            socket.onPong = { [weak self] (Void) in
                guard let processQueue = self?.processQueue else { return }
                processQueue.async(execute: { [weak self] in

//                debugPrint(". " + self.df.stringFromDate(NSDate()))
                    self?.resetPong()
                })
            }
            // This only works in newer versions of Starscream
            socket.disableSSLCertValidation = disableSSLValidation
            if(disableSSLValidation) {
                debugPrint("SSL Validation is turned off!")
            }
            debugPrint("trying to connect")
            socket.connect(pongTimeout)
        }
    }

    
    func sendPairingRequest() {
        processQueue.async(execute: { [weak self] in
            guard let strongSelf = self else { return }

            let pairingRequest = PairingRequest(name: strongSelf.name, serialNumber: strongSelf.serialNumber, token: strongSelf.pairingAuthToken)
            let pairingRequestMessage = PairingRequestMessage(request: pairingRequest)
            pairingRequestMessage.method = PairingCode.PAIRING_REQUEST
            if let pairingRequestString = Mapper().toJSONString(pairingRequestMessage)
            {
                strongSelf.sendMessage(pairingRequestString)
            } else {
                debugPrint("Error send pairing request!")
            }
        })
    }
    
    fileprivate func resetPong() {
        processQueue.async(execute: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.disconnectTimer?.invalidate()
            strongSelf.reportDisconnectTimer?.invalidate()
            if strongSelf.reportedDisconnect {
                DispatchQueue.main.async {
                    for obs in strongSelf.observers {
                        obs.onDeviceReady(strongSelf)
                    }
                }
            }
            strongSelf.reportedDisconnect = false
            strongSelf.schedulePing()
        })
    }
    
    fileprivate func schedulePing() {
        processQueue.async(execute: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.reportedDisconnect = false
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.pingTimer?.invalidate()
                strongSelf.pingTimer = Timer.scheduledTimer(timeInterval: Double(strongSelf.pingFrequency), target: strongSelf, selector: #selector(strongSelf.sendPing), userInfo: nil, repeats: false)
            }
        })
    }
    @objc fileprivate func sendPing() {
        processQueue.async(execute: { [weak self] in
            guard let strongSelf = self else { return }
            if let socket = strongSelf.socket {
                strongSelf.scheduleDisconnect()
//                debugPrint("sending PING " + strongSelf.df.stringFromDate(NSDate()))
                socket.write(ping: Data())
            }
        })
    }
    
    fileprivate func scheduleDisconnect() {
        processQueue.async(execute: { [weak self] in
            guard let strongSelf = self else { return }

            // if requested to be told of disconnect before we force a disconnect
            if strongSelf.reportConnectionProblemAfter < strongSelf.pongTimeout {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.reportDisconnectTimer?.invalidate()
                    strongSelf.reportDisconnectTimer = Timer.scheduledTimer(timeInterval: Double(strongSelf.reportConnectionProblemAfter), target: strongSelf, selector: #selector(strongSelf.reportDisconnect), userInfo: nil, repeats: false)
                }
            }
        
            strongSelf.disconnectTimer?.invalidate()
            strongSelf.disconnectTimer = Timer.scheduledTimer(timeInterval: Double(strongSelf.pongTimeout), target: strongSelf, selector: #selector(strongSelf.disconnectMissedPong), userInfo: nil, repeats: false)
        })
    }
    @objc fileprivate func reportDisconnect() {
        processQueue.async(execute: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.reportedDisconnect = true
            DispatchQueue.main.async {
                for obs in strongSelf.observers {
                    obs.onDeviceConnected(strongSelf)
                }
            }
        })
    }
    @objc fileprivate func disconnectMissedPong() {
        processQueue.async(execute: { [weak self] in
            guard let strongSelf = self else { return }

            if let ws = strongSelf.socket,
                let _ = strongSelf.endpoint {
                debugPrint("forcing disconnect " + strongSelf.df.string(from: Date()))
                ws.disconnect(forceTimeout: 0)
            } else {
                strongSelf.dispose()
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
//        debugPrint("Sending raw message: " + message)
        debugPrint("Sending raw message: " + String(message.characters.count))
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
