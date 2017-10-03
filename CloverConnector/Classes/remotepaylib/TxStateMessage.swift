//
//  TxStateMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class TxStateMessage : Message {
    
    public var txState:TxState?
    
    public required init?(map:Map) {
        super.init(method: .TX_STATE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        txState <- map["txState"]
    }
}
