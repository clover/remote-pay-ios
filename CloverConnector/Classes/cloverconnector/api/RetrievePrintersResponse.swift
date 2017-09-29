//
//  RetrievePrintersResponse.swift
//  Pods
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public class RetrievePrintersResponse: NSObject {
    public private(set) var printers: [CLVModels.Printer.Printer]?
    
    init(_ printers: [CLVModels.Printer.Printer]?) {
        self.printers = printers
    }
}
