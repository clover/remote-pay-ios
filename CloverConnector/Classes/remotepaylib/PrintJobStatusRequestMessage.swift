//
//  PrintJobStatusRequestMessage.swift
//  Pods
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public class PrintJobStatusRequestMessage : Message {
    var printRequestId: String?
    
    public init() {
        super.init(method: .PRINT_JOB_STATUS_REQUEST)
    }
    
    public required init?(map:Map) {
        super.init(method: .PRINT_JOB_STATUS_REQUEST)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        printRequestId <- map["externalPrintJobId"]
    }
}

