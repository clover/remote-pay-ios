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
        var kp:Int?
        switch(keyPress) {
        case .none: kp = 0;
        case .esc: kp = 41;
        case .enter: kp = 40
        case .backspace: kp = 42
        case .tab: kp = 43
        case .star: kp = 85
        case .button_1: kp = 58
        case .button_2: kp = 59
        case .button_3: kp = 60
        case .button_4: kp = 61
        case .button_5: kp = 62
        case .button_6: kp = 63
        case .button_7: kp = 64
        case .button_8: kp = 65
        case .digit_1: kp = 89
        case .digit_2: kp = 90
        case .digit_3: kp = 91
        case .digit_4: kp = 92
        case .digit_5: kp = 93
        case .digit_6: kp = 94
        case .digit_7: kp = 95
        case .digit_8: kp = 96
        case .digit_9: kp = 97
        case .digit_0: kp = 98
        }
        self.keyPress = keyPress.rawValue as String
    }
    
    required public init?(_ map: Map) {
        super.init(method: .KEY_PRESS)
        
    }
    
    public override func mapping(map:Map) {
        super.mapping(map)
        keyPress <- map["keyPress"]
    }
}
