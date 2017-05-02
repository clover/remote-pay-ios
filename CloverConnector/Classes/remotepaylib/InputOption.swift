//
//  InputOption.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

@objc
public class InputOption : NSObject, Mappable {
    public private(set) var keyPress:KeyPress?
    //open override fileprivate(set) var description:String
    private var _desc:String
    public override var description:String {
        get
        {
            return _desc
        }
        set
        {
            _desc = newValue
        }
    }
    
    public init(keyPress:KeyPress, description:String) {
        self.keyPress = keyPress
        self._desc = description
    }
    
    public override required init() {
        self._desc = ""
        super.init()
    }
    
    public required init(_ map:Map){
        _desc = ""
        super.init()
    }
    
    public func mapping(map:Map) {
        let keyPressTransform = TransformOf<KeyPress, String>(fromJSON: { (value: String?) -> KeyPress? in
            if let value = value {
                return KeyPress(rawValue: value as String)
            }
            return nil
            }, toJSON: { (value: KeyPress?) -> String? in
                if let value = value {
                    return "\(value)"
                }
                return nil
        })
        keyPress <- (map["keyPress"], keyPressTransform)
        //keyPress <- map["keyPress"]
        description <- map["description"]
    }
}

