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
    private var missedPongs:Int = 0
    private var disconnectTimer:NSTimer?
    private var endpoint:NSURL?
    
    private var name:String = ""
    private var serialNumber = ""
    private var pairingAuthToken:String?
    private var pairingConfig:PairingDeviceConfiguration
    
//    private var disableSSLValidation:Bool = false
    
    private var reconnectDelay = 2 // period between attempting reconnect
    private var missedPongsBeforeDisconnect = 4 // how many pingFrequency missed before forcing a disconnect
    private var pingFrequency = 5 // period between pings in seconds
    
    init?(endpointURL: String, posName:String, serialNumber:String, pairingAuthToken: String?, pairingDeviceConfiguration:PairingDeviceConfiguration, pingFrequency pf:Int? = 5, missedPongsBeforeDisconnect mp:Int? = 6, reconnectDelay rd:Int? = 2) {

        self.pairingAuthToken = pairingAuthToken
        self.name = posName
        self.serialNumber = serialNumber
        self.pairingConfig = pairingDeviceConfiguration
//        self.disableSSLValidation = disableSSLCertificateValidation
        self.pingFrequency = pf ?? 5
        self.missedPongsBeforeDisconnect = mp ?? 4
        self.reconnectDelay = rd ?? 2
        
        super.init()
        
        if let endpoint = NSURL(string: endpointURL) {
            self.endpoint = endpoint
            initialize(endpoint)
        } else {
            return nil
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
                print(error?.userInfo[NSUnderlyingErrorKey])
                for obs in self.observers {
                    (obs as! CloverTransportObserver).onDeviceDisconnected(self)
                }
                self.disconnectTimer?.invalidate()
                self.missedPongs = 0
                
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
                debugPrint("got some text: \(text)")
                
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
                                //self.sendPairingRequest()
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
                    for obs in self.observers {
                        (obs as! CloverTransportObserver).onMessage(text)
                    }
                }
            }
            
            socket.onData = { (data: NSData) in
                debugPrint("got some data: \(data)") // don't expect this
            }
            socket.onPong = { (Void) in
                debugPrint("got pong...")
                self.missedPongs = 0
                self.disconnectTimer?.invalidate()
                self.schedulePing()
            }
            // This only works in newer versions of Starscream
//            socket.disableSSLCertValidation = disableSSLValidation
//            if(disableSSLValidation) {
//                debugPrint("SSL Validation is turned off!")
//                // TODO: add ALog call through API to log this!
//            }
//            socket.timeout = 1 // seconds
            debugPrint("trying to connect")
            socket.connect(5)
//            schedulePing()// because the socket doesn't always timeout quickly if there is no server, we use the missed pings to force it...ugly
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
    
    private func schedulePing() {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(pingFrequency) * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if let socket = self.socket {
                socket.writePing(NSData())
                self.scheduleDisconnect()
            }
        })
    }
    private func scheduleDisconnect() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if let dt = self.disconnectTimer {
                dt.invalidate()
            }
            self.disconnectTimer = NSTimer.scheduledTimerWithTimeInterval(Double(self.pingFrequency), target: self, selector: #selector(self.disconnectMissedPong), userInfo: nil, repeats: false)
        })
    }
    
    @objc private func disconnectMissedPong() {
        debugPrint("Missed pong \(missedPongs + 1)")
        // TODO: should we send an onDeviceConnected, so the calls fail until we get a pong back?
        missedPongs += 1
        if missedPongs >= missedPongsBeforeDisconnect || !(self.socket?.isConnected ?? false) {
            if let ws = socket,
                let endpoint = endpoint {
                ws.disconnect(forceTimeout: 0)
            } else {
                dispose()
                // should we initialize here? how do we get in this state without messing up the state of the Transport?
            }
        } else {
            scheduleDisconnect()
        }
    }
    
    public override func dispose() {
        disconnectTimer?.invalidate()
        if let ws = socket {
            ws.disconnect()
        }
        disposed = true
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
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(timeout) * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if !self.isConnected {
                self.disconnect(forceTimeout: 0)
            }
        })
    }
}
