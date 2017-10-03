//
//  VaultCardMessage.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
//import CloverSDK

public class VaultCardMessage : Message {
    public var cardEntryMethods:Int?
    
    public init() {
        super.init(method: .VAULT_CARD)
    }
    
    public required init?(map:Map) {
        super.init(method: .VAULT_CARD)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        cardEntryMethods <- map["cardEntryMethods"]
    }
}
