//
//  FinishCancelMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class FinishCancelMessage : Message {
    public var requestInfo:String?
    
    public required init?(map:Map) {
        super.init(method: Method.FINISH_CANCEL)
    }
}
