//
//  ShowWelcomeScreenMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/*
The message sent to the clover device upon connection
*/
public class ShowThankYouScreenMessage:Message {

    
    public required init() {
        super.init(method: .SHOW_THANK_YOU_SCREEN)
    }
    
    required public init?(map:Map){
        super.init(method: .SHOW_THANK_YOU_SCREEN)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
    }
    
}

