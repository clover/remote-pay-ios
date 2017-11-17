//
//  PrintJobStatusResponseMessage.swift
//  Pods
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper


public class PrintJobStatusResponseMessage : Message {
    var printRequestId: String?
    var status: String?
    
    public init() {
        super.init(method: .PRINT_JOB_STATUS_RESPONSE)
    }
    
    public required init?(map:Map) {
        super.init(method: .PRINT_JOB_STATUS_RESPONSE)
    }
    
    public override func mapping(map:Map) {
        super.mapping(map: map)
        printRequestId <- map["externalPrintJobId"]
        status <- map["status"]
    }
}
