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
            print("endpoint is nil", __stderrp)
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
            socket.onConnect = {
                print("websocket is connected")
                pairing = true

                self.schedulePing()
                self.sendPairingRequest()
            }
            socket.onDisconnect = { (error: NSError?) in
                print("websocket is disconnected: \(error?.localizedDescription)")
                //print(error?.userInfo[NSUnderlyingErrorKey])
                for obs in self.observers {
                    (obs as! CloverTransportObserver).onDeviceDisconnected(self)
                }
                self.disconnectTimer?.invalidate()
                self.reportDisconnectTimer?.invalidate()
                
                self.socket = nil
                
                if(self.disposed) {
                    return
                }
                
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(self.reconnectDelay) * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    self.initialize(endpoint)
                })
            }
            
            socket.onText = { (text: String) in
                debugPrint("websocket onText: \(text)")
                self.resetPong()
                if (pairing) {
                    //
                    let parser:Mapper<PairingResponseMessage> = Mapper<PairingResponseMessage>()
                    var remoteMessage = parser.map(text)
                    if(remoteMessage?.method == PairingCode.PAIRING_CODE) {
                        if let pcm:PairingCodeMessage = Mapper<PairingCodeMessage>().map((remoteMessage?.payload)!) {
                            debugPrint("Got pairing code: \(pcm.pairingCode)")
                            self.pairingConfig.onPairingCode(pcm.pairingCode!)
                        } else {
                            debugPrint("Error getting pairing code from: \(text)", stderr)
                        }
                        
                    } else if (remoteMessage?.method == PairingCode.PAIRING_RESPONSE) {
                        if let pr:PairingResponse = Mapper<PairingResponse>().map((remoteMessage?.payload)!) {
                            if pr.pairingState == PairingCode.INITIAL || pr.pairingState == PairingCode.PAIRED {
                                pairing = false;
                                self.pairingAuthToken = pr.authenticationToken
                                debugPrint("pairing successful \(pr.authenticationToken)")
                                self.pairingConfig.onPairingSuccess(pr.authenticationToken!)
                                
                                for obs in self.observers {
                                    (obs as! CloverTransportObserver).onDeviceReady(self)
                                }
                            } else if pr.pairingState == PairingCode.FAILED {
                                pairing = true
                                debugPrint("pairing failed")
                                self.pairingAuthToken = nil
                                //self.sendPairingRequest() // fail causes a disconnect, so this is taken care of in reconnect
                            }
                        }
                    } else {
                        if(remoteMessage?.method != "ACK" && remoteMessage?.method != "UI_STATE") {
                            debugPrint("Error parsing message: \(text)", stderr)
                        } else {
                            // we expect ACK and UI_STATE messages while pairing
                        }
                    }

                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                        for obs in self.observers {
                            (obs as! CloverTransportObserver).onMessage(text)
                        }
                    }
                }
            }
            
            socket.onData = { (data: NSData) in
                debugPrint("got some data: \(data)") // don't expect this
            }
            socket.onPong = { (Void) in
//                print(". \(self.df.stringFromDate(NSDate()))")
                self.resetPong()
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
        let pairingRequest = PairingRequest(name: name, serialNumber: serialNumber, token: pairingAuthToken)
        let pairingRequestMessage = PairingRequestMessage(request: pairingRequest)
        pairingRequestMessage.method = PairingCode.PAIRING_REQUEST
        if let pairingRequestString = Mapper().toJSONString(pairingRequestMessage)
        {
            sendMessage(pairingRequestString)
        } else {
            print("Error send pairing request!")
        }
        
    }
    
    private func resetPong() {
        if let dt = self.disconnectTimer {
            if dt.valid {
                dt.invalidate()
//                print("invalidated")
            } else {
//                print("not invalidated!")
            }
//            print("timer is valid? \(self.disconnectTimer?.valid)")
        }
        self.reportDisconnectTimer?.invalidate()
        if reportedDisconnect {
            dispatch_async(dispatch_get_main_queue()) {
                for obs in self.observers {
                    (obs as! CloverTransportObserver).onDeviceReady(self)
                }
            }
        }
        reportedDisconnect = false
        self.schedulePing()
    }
    
    private func schedulePing() {
        reportedDisconnect = false
        dispatch_async(dispatch_get_main_queue()) {
            if let pt = self.pingTimer {
                pt.invalidate()
            }
            self.pingTimer = NSTimer.scheduledTimerWithTimeInterval(Double(self.pingFrequency), target: self, selector: #selector(self.sendPing), userInfo: nil, repeats: false)
        }
    }
    @objc private func sendPing() {
        if let socket = self.socket {
//            print("sending PING \(df.stringFromDate(NSDate()))")
            socket.writePing(NSData())
            self.scheduleDisconnect()
        }
    }
    
    private func scheduleDisconnect() {
        // if requested to be told of disconnect before we force a disconnect
        if reportConnectionProblemAfter < pongTimeout {
            dispatch_async(dispatch_get_main_queue()) {
                if let rdt = self.reportDisconnectTimer {
                    rdt.invalidate()
                }
                self.reportDisconnectTimer = NSTimer.scheduledTimerWithTimeInterval(Double(self.reportConnectionProblemAfter), target: self, selector: #selector(self.reportDisconnect), userInfo: nil, repeats: false)
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            if let dt = self.disconnectTimer {
                dt.invalidate()
            }
            self.disconnectTimer = NSTimer.scheduledTimerWithTimeInterval(Double(self.pongTimeout), target: self, selector: #selector(self.disconnectMissedPong), userInfo: nil, repeats: false)
        }
    }
    @objc private func reportDisconnect() {
        reportedDisconnect = true
        dispatch_async(dispatch_get_main_queue()) {
            for obs in self.observers {
                (obs as! CloverTransportObserver).onDeviceConnected(self)
            }
        }
    }
    @objc private func disconnectMissedPong() {

        if let ws = socket,
            let endpoint = endpoint {
            print("forcing disconnect \(df.stringFromDate(NSDate()))")
            ws.disconnect(forceTimeout: 0)
        } else {
            dispose()
            // should we initialize here? how do we get in this state without messing up the state of the Transport?
        }
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
        Swift.print("Sending raw message: \(message)")
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
