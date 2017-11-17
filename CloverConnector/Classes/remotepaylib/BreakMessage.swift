//
//  BreakMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class BreakMessage : Message {
    
    public required init() {
        super.init(method: .BREAK)
    }
    public required init(map:Map) {
        super.init(method: .BREAK)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
    }
}
