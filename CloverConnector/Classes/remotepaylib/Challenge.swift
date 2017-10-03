//
//  Challenge.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

import ObjectMapper
//import CloverSDK

public class Challenge : Mappable {
    public var message:String?
    public var reason:VoidReason?
    public var type:ChallengeType?
    
    public required init?(map:Map) {
        
    }
    
    public func mapping(map:Map) {
        message <- map["message"]
        reason <- map["reason"]
        type <- map["type"]
    }
}

public enum ChallengeType : String {
    case DUPLICATE_CHALLENGE = "DUPLICATE_CHALLENGE"
    case OFFLINE_CHALLENGE = "OFFLINE_CHALLENGE"
}
