//
//  KeyPressMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class KeyPressMessage : Message {
    var keyPress:String?
    
    public init() {
        super.init(method: .KEY_PRESS)
    }
    
    public init(keyPress:KeyPress) {
        super.init(method: .KEY_PRESS)
        
        self.keyPress = keyPress.rawValue as String
    }
    
    required public init?(map:Map) {
        super.init(method: .KEY_PRESS)
        
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        keyPress <- map["keyPress"]
    }
}
