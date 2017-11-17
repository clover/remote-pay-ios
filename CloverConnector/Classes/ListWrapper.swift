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
        let items = jsonObj.value(forKey: "elements")
        
        if let items = items as? NSArray {
            for obj in items {
                if let obj = obj as? Map,
                    let mapObj = T.self.init(map: obj) {
                    elements.append(mapObj)
                }
            }
        } else {
            debugPrint("Expected an array, but got something else: " + String(describing: items));
        }
    }
    
    public init() {
        
    }
    
    public required init?(map:Map) {
        
    }
    
    public func mapping(map:Map) {
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
        let items = jsonObj.value(forKey: "elements")
        
        if let validItems = items as? NSArray {
            for obj in validItems {
                if let elType:String = obj as? String {
                    elements.add(elType)
                }
            }
            
        } else {
            debugPrint("Expected an array, but got something else: " + String(describing: items));
        }
    }
    
    public func addElement(_ obj:String) {
        elements.add(obj)
    }
    
    public func removeElement(_ obj:String) {
        elements.remove(obj);
    }
    
    public func count() {
        let _ = elements.count
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
