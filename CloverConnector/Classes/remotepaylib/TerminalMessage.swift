//
//  TerminalMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public class TerminalMessage : Message {
    public var text:String?
    
    public required init() {
        super.init(method: .TERMINAL_MESSAGE)
    }
    
    required public init?(map:Map) {
        super.init(method: .TERMINAL_MESSAGE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        text <- map["text"]
    }
}
