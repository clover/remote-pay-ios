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
    private var disposed = false
    private var reportDisconnectTimer:NSTimer? // if the client wants to be notified sooner than an actual timeout, this timer will do it
    private var disconnectTimer:NSTimer? // if a pong hadn't been received in this amount of time after a ping is sent, disconnect the websocket
    private var pingTimer:NSTimer? // how long after a pong will the next ping be sent
    private var endpoint:NSURL?
    
    private var processQueue = dispatch_queue_create("com.clover.webSocketProcessingQueue", nil) // serial dispatch queue to handle the processing in and out of data
    
    private var reportedDisconnect = false // keeps track if a deviceDisconnected message has been sent to the client, before it is actually disconnected so
                                        // if the pong is received before disconnect timeout, a deviceReady needs to be sent
    
    private var name:String = ""
    private var serialNumber = ""
    private var pairingAuthToken:String?
    private var pairingConfig:PairingDeviceConfiguration
    
//    private var disableSSLValidation:Bool = false
    
    private var reconnectDelay = 2 // delay before attempting reconnect
    private var pingFrequency = 3 // period between pings in seconds
    private var pongTimeout = 20 // how long to wait for a pong before closing connection
    private var reportConnectionProblemAfter = 20 // if pong hasn't come back in this time, report as disconnected but still wait
    
    let df = NSDateFormatter()

    deinit {
        debugPrint("deinit WebSocketCloverTransport")
    }

    
    init?(endpointURL: String, posName:String, serialNumber:String, pairingAuthToken: String?, pairingDeviceConfiguration:PairingDeviceConfiguration, pongTimeout pt:Int? = 15, pingFrequency pf:Int? = 3, reconnectDelay rd:Int? = 2, reportConnectionProblemAfter rt:Int? = 20) {

        df.dateFormat = "y-MM-dd H:m:ss.SSSS"
        
        self.pairingAuthToken = pairingAuthToken
        self.name = posName
        self.serialNumber = serialNumber
        self.pairingConfig = pairingDeviceConfiguration
//        self.disableSSLValidation = disableSSLCertificateValidation
        self.pingFrequency = pf ?? 5
        self.pongTimeout = pt ?? 15
        self.reportConnectionProblemAfter = rt ?? 15
        self.reconnectDelay = rd ?? 2
        
        super.init()
        
        if let endpoint = NSURL(string: endpointURL) {
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
    
    func initialize(_ endpoint:NSURL) {
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
                dispatch_async(processQueue, { [weak self] in
                    debugPrint("websocket is connected")
                    pairing = true
                    
                    self?.schedulePing()
                    self?.sendPairingRequest()
                })
            }
            socket.onDisconnect = { [weak self] (error: NSError?) in
                guard let processQueue = self?.processQueue else { return }
                dispatch_async(processQueue, { [weak self] in
                    guard let strongSelf = self else {
                        debugPrint("onDisconnect called on orphaned socket")
                        return
                    }
                    
                    if let error = error {
                        debugPrint("websocket is disconnected: " + error.localizedDescription)
                        
                        for obs in strongSelf.observers {
                            (obs as! CloverTransportObserver).onDeviceError(.CONNECTION_ERROR, int: error.code, cause:error, message: error.localizedDescription)
                        }
                    } else {
                        debugPrint("websocket is disconnected")
                    }
                    
                    for obs in strongSelf.observers {
                        (obs as! CloverTransportObserver).onDeviceDisconnected(strongSelf)
                    }
                    
                    strongSelf.disconnectTimer?.invalidate()
                    strongSelf.reportDisconnectTimer?.invalidate()
                    
                    strongSelf.socket = nil
                    
                    if strongSelf.disposed {
                        return
                    }
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(strongSelf.reconnectDelay) * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        strongSelf.initialize(endpoint)
                    })
                })
            }
            
            socket.onText = { [weak self] (text: String) in
                guard let processQueue = self?.processQueue else { return }
                dispatch_async(processQueue, { [weak self] in
                    guard let strongSelf = self else {
                        debugPrint("onText called on orphaned socket")
                        return
                    }
                    
                    debugPrint("websocket onText: " + text)
                    strongSelf.resetPong()
                    if (pairing) {
                        let parser:Mapper<PairingResponseMessage> = Mapper<PairingResponseMessage>()
                        var remoteMessage = parser.map(text)
                        if(remoteMessage?.method == PairingCode.PAIRING_CODE) {
                            if let pcm:PairingCodeMessage = Mapper<PairingCodeMessage>().map((remoteMessage?.payload)!), let code = pcm.pairingCode {
                                debugPrint("Got pairing code: " + code)
                                strongSelf.pairingConfig.onPairingCode(code)
                            } else {
                                debugPrint("Error getting pairing code from: " + text, stderr)
                            }
                            
                        } else if (remoteMessage?.method == PairingCode.PAIRING_RESPONSE) {
                            if let pr:PairingResponse = Mapper<PairingResponse>().map((remoteMessage?.payload)!), let authToken = pr.authenticationToken {
                                if pr.pairingState == PairingCode.INITIAL || pr.pairingState == PairingCode.PAIRED {
                                    pairing = false;
                                    strongSelf.pairingAuthToken = authToken
                                    debugPrint("pairing successful " + authToken)
                                    strongSelf.pairingConfig.onPairingSuccess(authToken)
                                    
                                    for obs in strongSelf.observers {
                                        (obs as! CloverTransportObserver).onDeviceReady(strongSelf)
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
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                            for obs in strongSelf.observers {
                                (obs as! CloverTransportObserver).onMessage(text)
                            }
                        }
                    }
                })
            }
            
            socket.onData = { [weak self] (data: NSData) in
                guard let processQueue = self?.processQueue else { return }
                dispatch_async(processQueue, { [weak self] in
                    debugPrint("got some data: " + String(data)) // don't expect this
                })
            }
            socket.onPong = { [weak self] (Void) in
                guard let processQueue = self?.processQueue else { return }
                dispatch_async(processQueue, { [weak self] in

//                debugPrint(". " + self.df.stringFromDate(NSDate()))
                    self?.resetPong()
                })
            }
            // This only works in newer versions of Starscream
//            socket.disableSSLCertValidation = disableSSLValidation
//            if(disableSSLValidation) {
//                debugPrint("SSL Validation is turned off!")
//                // TODO: add ALog call through API to log this!
//            }
            debugPrint("trying to connect")
            socket.connect(pongTimeout)
        }
    }

    
    func sendPairingRequest() {
        dispatch_async(processQueue, { [weak self] in
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
    
    private func resetPong() {
        dispatch_async(processQueue, { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.disconnectTimer?.invalidate()
            strongSelf.reportDisconnectTimer?.invalidate()
            if strongSelf.reportedDisconnect {
                dispatch_async(dispatch_get_main_queue()) {
                    for obs in strongSelf.observers {
                        (obs as! CloverTransportObserver).onDeviceReady(strongSelf)
                    }
                }
            }
            strongSelf.reportedDisconnect = false
            strongSelf.schedulePing()
        })
    }
    
    private func schedulePing() {
        dispatch_async(processQueue, { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.reportedDisconnect = false
            dispatch_async(dispatch_get_main_queue()) {
                if let pt = strongSelf.pingTimer {
                    pt.invalidate()
                }
                strongSelf.pingTimer = NSTimer.scheduledTimerWithTimeInterval(Double(strongSelf.pingFrequency), target: strongSelf, selector: #selector(strongSelf.sendPing), userInfo: nil, repeats: false)
            }
        })
    }
    @objc private func sendPing() {
        dispatch_async(processQueue, { [weak self] in
            guard let strongSelf = self else { return }
            if let socket = strongSelf.socket {
                strongSelf.scheduleDisconnect()
//                debugPrint("sending PING " + strongSelf.df.stringFromDate(NSDate()))
                socket.writePing(NSData())
            }
        })
    }
    
    private func scheduleDisconnect() {
        dispatch_async(processQueue, { [weak self] in
            guard let strongSelf = self else { return }

            // if requested to be told of disconnect before we force a disconnect
            if strongSelf.reportConnectionProblemAfter < strongSelf.pongTimeout {
                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.reportDisconnectTimer?.invalidate()
                    strongSelf.reportDisconnectTimer = NSTimer.scheduledTimerWithTimeInterval(Double(strongSelf.reportConnectionProblemAfter), target: strongSelf, selector: #selector(strongSelf.reportDisconnect), userInfo: nil, repeats: false)
                }
            }
        
//            debugPrint("Scheduling Disconnect for " + String(strongSelf.pongTimeout) + " Seconds at " + strongSelf.df.stringFromDate(NSDate(timeInterval: Double(strongSelf.pongTimeout), sinceDate:NSDate())))
            
            strongSelf.disconnectTimer?.invalidate()
            strongSelf.disconnectTimer = NSTimer.scheduledTimerWithTimeInterval(Double(strongSelf.pongTimeout), target: strongSelf, selector: #selector(strongSelf.disconnectMissedPong), userInfo: nil, repeats: false)
        })
    }
    @objc private func reportDisconnect() {
        dispatch_async(processQueue, { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.reportedDisconnect = true
            dispatch_async(dispatch_get_main_queue()) {
                for obs in strongSelf.observers {
                    (obs as! CloverTransportObserver).onDeviceConnected(strongSelf)
                }
            }
        })
    }
    @objc private func disconnectMissedPong() {
        dispatch_async(processQueue, { [weak self] in
            guard let strongSelf = self else { return }

            if let ws = strongSelf.socket,
                let endpoint = strongSelf.endpoint {
                debugPrint("forcing disconnect " + strongSelf.df.stringFromDate(NSDate()))
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
    
    override func sendMessage(_ message: String) -> Int {
//        debugPrint("Sending raw message: " + message)
        debugPrint("Sending raw message: " + String(message.characters.count))
        if let socket = socket {
            socket.writeString(message)
        }
        return 0
    }
    
    func reconnect() {
        
    }

}

extension WebSocket {
    public func connect(timeoutInSec: Int) {
        connect()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(timeoutInSec) * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if !self.isConnected {
                self.disconnect(forceTimeout: 0)
            }
        })
    }
}
