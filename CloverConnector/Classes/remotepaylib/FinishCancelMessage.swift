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
    
    public required init?(_ map:Map) {
        super.init(method: Method.FINISH_CANCEL)
    }
}
