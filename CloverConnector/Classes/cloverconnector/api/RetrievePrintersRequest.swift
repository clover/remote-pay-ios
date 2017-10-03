//
//  RetrievePrintersRequest.swift
//  Pods
//
//  Created by Daniel James on 8/25/17.
//
//

import Foundation

public class RetrievePrintersRequest: NSObject {
    var category: PrintCategory?
    
    public init(printerCategory: PrintCategory?) {
        self.category = printerCategory
    }
}

public enum PrintCategory {
    case order
    case receipt
}
