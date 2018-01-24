//
//  RetrievePrintersResponse.swift
//  Pods
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class RetrievePrintersResponse: BaseResponse {
    public fileprivate(set) var printers: [CLVModels.Printer.Printer]?
    
    init(_ printers: [CLVModels.Printer.Printer]?) {
        //success status isn't explicitly provided by the server, so we consider it a "success" if printers array is non-nil
        if printers != nil {
            super.init(success: true, result: .SUCCESS)
        } else {
            super.init(success: false, result: .ERROR)
        }

        self.printers = printers
    }
    
    required public init?(map:Map) {
        super.init(success: false, result: .FAIL) //shouldn't init here, so default to failure if we do
    }
}
