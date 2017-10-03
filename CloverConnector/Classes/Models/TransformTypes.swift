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

