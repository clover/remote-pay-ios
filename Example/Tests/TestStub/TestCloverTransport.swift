//
//  TestCloverTransport.swift
//  CloverConnector
//
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
@testable import CloverConnector

class TestCloverTransport: CloverTransport {
    
    var onMessageCallback:((_ message: [String:Any])->())?

    override func initialize() {
        debugPrint("TestCloverTransport.initialize")
    }
    
    
    @discardableResult
    override func sendMessage(_ message: String) -> Int {
        if let dictionary = stringToDict(string:message) {
            DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 0.01, execute: { [weak self] in
                self?.onMessageCallback?(dictionary)
            })
        } else {
            print("Error parsing Input String")
        }
        return 0
    }
    
    func stringToDict(string:String) -> [String:Any]? {
        guard let data = string.data(using: .utf8) else { return nil }
        var dictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any]
        if let validDictionary = dictionary {
            for (key,value) in validDictionary {
                if let value = value as? String {
                    dictionary?[key] = stringToDict(string: value) ?? value
                }
            }
        }
        return dictionary
    }
}
