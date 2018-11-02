//
//  Loyalty.swift
//  CloverConnector
//
//  Copyright © 2018 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

extension CLVModels {
    public class Loyalty {

        
        public class LoyaltyDataConfig : NSObject, Mappable {
            public var type:String?
            public var configuration:[String:String]?
            
            public init(configuration:[String:String]?, type:String?) {
                super.init()
                self.configuration = configuration
                self.type = type
            }
            /// :nodoc:
            required public init?(map:Map) {
                
            }
            /// :nodoc:
            public func mapping(map:Map) {
                type <- map["type"]
                configuration <- map["configuration"]
            }
        }
        
        public class Offer: Mappable {
            public var id:String?
            public var label:String?
            public var description:String?
            public var cost:Int?
            
            public init(id:String?=nil,label:String?=nil,description:String?=nil,cost:Int?=nil) {
                self.id = id
                self.label = label
                self.description = description
                self.cost = cost
            }
            
            public required init?(map:Map) {
                
            }
            
            public func mapping(map:Map) {
                id <- map["id"]
                label <- map["label"]
                description <- map["description"]
                cost <- map["cost"]
            }
        }
        
        
        public class LoyaltyDataTypes {
            public static let VAS_TYPE:String = "VAS"
            public static let EMAIL_TYPE:String = "EMAIL"
            public static let PHONE_TYPE:String = "PHONE"
            public static let CLEAR_TYPE:String = "CLEAR"
            
            public class VAS_TYPE_KEYS {
                public static let PUSH_URL:String = "PUSH_URL"
                public static let PROTOCOL_CONFIG:String = "PROTOCOL_CONFIG"
                public static let PROTOCOL_ID:String = "PROTOCOL_ID"
                public static let PROVIDER_PACKAGE:String = "PROVIDER_PACKAGE"
                public static let PUSH_TITLE:String = "PUSH_TITLE"
                public static let SUPPORTED_SERVICES:String = "SUPPORTED_SERVICES"
            }
        }
        
        public enum VasProtocol:String {
            case ST
            case PK
        }
        
        public enum VasDataTypeType:String, CaseIterable {
            case ALL
            case LOYALTY
            case OFFER
            case GIFT_CARD
            case PRIVATE_LABEL_CARD
            case CUSTOMER
            case VAS_DATA
            
            public static var allCasesJson:String? {
                return VasDataTypeType.casesJson(cases: VasDataTypeType.allCases)
            }
            public static func casesJson(cases:[VasDataTypeType]) -> String? {
                guard let data = try? JSONSerialization.data(withJSONObject: cases.map({$0.rawValue}), options: .prettyPrinted) else { return nil }
                return String(data: data, encoding: .utf8)
            }
        }
    }
}
