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
  public typealias Object = NSDate
  public typealias JSON = Double
  
  public init() {}
    
    public func transformFromJSON(_ value: AnyObject?) -> NSDate? {
        guard let timeInt = value as? Double else { return nil }
        return NSDate(timeIntervalSince1970: NSTimeInterval(timeInt / 1000))
    }
  
  /*public func transformFromJSON(value: Any?) -> Date? {
    guard let timeInt = value as? Double else { return nil }
    return Date(timeIntervalSince1970: TimeInterval(timeInt / 1000))
  }*/
  
  public func transformToJSON(_ value: NSDate?) -> Double? {
    guard let date = value else { return nil }
    return date.timeIntervalSince1970 * 1000
  }
}

/*public class CLVArrayTransform<T: Mappable>: TransformType {

  public typealias Object = [T]
  public typealias JSON = AnyObject
  
  public init() {}
  
    public func transformFromJSON(_ value: Any?) -> Array<T>? {
        //if let obj = value as? NSDictionary, let arr = obj.value(forKey: "elements") as? NSArray {
        //    return arr.map({ item in Mapper<T>().map(JSONObject: item as? Array<T> ?? item)! })
        //}
        //return nil
        
        guard let obj = value as? NSDictionary else { return nil }
        guard let arr = obj.value(forKey: "elements") as? NSArray else { return nil }
        return arr.map({ item in Mapper<T>().map(JSONObject: item)!})

        //return arr.map({ item in Mapper<T>().map(item as! [T])! })
    }
    
    public func transformToJSON(_ value: [T]?) -> AnyObject? {
        guard let val = value else { return nil }
        let arrayList = NSMutableArray()//[String].init()
        for item in val {
            arrayList.add(Mapper<T>().toJSON(item))
        }
        return arrayList
        //return Mapper<T>().toJSONArray(value)
    }
    

}*/
