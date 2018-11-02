//
//  TransformTypes.swift
//  CloverSDK
//
//  Created by Yusuf on 12/24/15.
//  Copyright © 2015 Clover Network, Inc. All rights reserved.
//
import Foundation
import SwiftyJSON
import ObjectMapper

public class CLVDateTransform: TransformType {
  public typealias Object = Date
  public typealias JSON = Double
  
  public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Date? {
        guard let timeInt = value as? Double else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(timeInt / 1000))
    }
  
  /*public func transformFromJSON(value: Any?) -> Date? {
    guard let timeInt = value as? Double else { return nil }
    return Date(timeIntervalSince1970: TimeInterval(timeInt / 1000))
  }*/
  
  public func transformToJSON(_ value: Date?) -> Double? {
    guard let date = value else { return nil }
    return date.timeIntervalSince1970 * 1000
  }
}

public class CLVTransforms {
    public class Customer {
        static let customer = TransformOf<CLVModels.Customers.Customer, String>(fromJSON: { (value: String?) -> CLVModels.Customers.Customer? in
            if let val = value,
                let pi = Mapper<CLVModels.Customers.Customer>().map(JSONString: val) {
                return pi
            }
            return nil
        }, toJSON: { (obj: CLVModels.Customers.Customer?) -> String? in
            if obj != nil {
                if let val = obj,
                    let value = Mapper().toJSONString(val, prettyPrint:false) {
                    return String(value)
                }
            }
            return nil
        })
        static let customerInfo = TransformOf<CLVModels.Customers.CustomerInfo, String>(fromJSON: { (value: String?) -> CLVModels.Customers.CustomerInfo? in
            if let val = value,
                let pi = Mapper<CLVModels.Customers.CustomerInfo>().map(JSONString: val) {
                return pi
            }
            return nil
        }, toJSON: { (obj: CLVModels.Customers.CustomerInfo?) -> String? in
            if obj != nil {
                if let val = obj,
                    let value = Mapper().toJSONString(val, prettyPrint:false) {
                    return String(value)
                }
            }
            return nil
        })
    }

    public class Loyalty {
        static let loyaltyDataConfig = TransformOf<CLVModels.Loyalty.LoyaltyDataConfig, String>(fromJSON: { (value: String?) -> CLVModels.Loyalty.LoyaltyDataConfig? in
            if let val = value,
                let pi = Mapper<CLVModels.Loyalty.LoyaltyDataConfig>().map(JSONString: val) {
                return pi
            }
            return nil
        }, toJSON: { (obj: CLVModels.Loyalty.LoyaltyDataConfig?) -> String? in
            if obj != nil {
                if let val = obj,
                    let value = Mapper().toJSONString(val, prettyPrint:false) {
                    return String(value)
                }
            }
            return nil
        })
    }
}
