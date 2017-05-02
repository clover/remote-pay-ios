//
//  ListWrapper.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

//
//  ListWrapper.swift
//  CloverSDKBase
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class ListWrapper<T:Mappable> : Mappable {
    var elements = Array<T>()
    
    public init(jsonObj:NSDictionary) {
        let items = jsonObj.valueForKey("elements")
        
        if items is NSArray {
            for var obj in (items as! NSArray) {
                let type = T.self
                let elType = type.init(obj as! Map)
                elements.append(elType!)
            }
            
        } else {
            Swift.print("Expected an array, but got something else:\(items)");
        }
    }
    
    public init() {
        
    }
    
    public required init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        elements <- map["elements"]
    }
    
    public func addElement(_ obj:T) {
        elements.append(obj)
        //elements.addObject(obj)
    }
    
    public func removeElement(_ obj:T) {
        //var idx = elements.indexOf({obj == $0})
        //elements.removeObject(obj);
    }
    
    public func getElement(_ index:Int) -> T {
        return elements[index]
    }
    
    public func count() -> Int {
        return elements.count
    }
}

public class Initable {
    public required init() {
        
    }
    public required init(jsonObj:NSDictionary) {
        
    }
}

public class StringListWrapper {
    let elements = NSMutableArray()
    
    public init(jsonObj:NSDictionary) {
        let items = jsonObj.valueForKey("elements")
        
        if items is NSArray {
            for var obj in (items as! NSArray) {
                let elType:String = String(obj as! String)
                elements.addObject(elType)
            }
            
        } else {
            Swift.print("Expected an array, but got something else:\(items)");
        }
    }
    
    public func addElement(_ obj:String) {
        elements.addObject(obj)
    }
    
    public func removeElement(_ obj:String) {
        elements.removeObject(obj);
    }
    
    public func count() {
        elements.count
    }
}

public class DictionaryWrapper<T,S> : Initable {
    var dict:NSDictionary?
    public required init() {
        super.init()
        dict = [String:String]() as NSDictionary?
    }
    
    public required init(jsonObj:NSDictionary) {
        super.init(jsonObj: jsonObj)
        self.dict = jsonObj
        //        self.addEntriesFromDictionary(jsonObj as [NSObject : AnyObject]) // TODO: get the types of the objects and deserialize them...
    }
}
