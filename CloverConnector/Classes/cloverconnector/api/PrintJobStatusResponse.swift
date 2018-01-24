//
//  PrintJobStatusResponse.swift
//  Pods
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class PrintJobStatusResponse: BaseResponse {
    public fileprivate(set) var printRequestId: String?
    public fileprivate(set) var status: PrintJobStatus
    
    init(_ printRequestId: String?, status: String?) {
        self.printRequestId = printRequestId
        
        guard let status = status else {
            self.status = .ERROR
            super.init()
            self.success = false //we expect a status from the server, so consider the query a failure if we don't have it
            return
        }
        
        switch status {
        case "IN_QUEUE":
            self.status = .IN_QUEUE
        case "PRINTING":
            self.status = .PRINTING
        case "DONE":
            self.status = .DONE
        case "ERROR":
            self.status = .ERROR
        case "UNKNOWN":
            self.status = .UNKNOWN
        case "NOT_FOUND":
            self.status = .NOT_FOUND
            
        default:
            self.status = .ERROR
        }
        
        super.init()
        self.success = true //the request is considered successful if we got a status
    }
    
    required public init?(map:Map) { //shouldn't init through here, so default to failure if we do
        self.status = .ERROR
        super.init(success: false, result: .FAIL)
    }
}


public enum PrintJobStatus: String {
    case IN_QUEUE   = "IN_QUEUE"
    case PRINTING   = "PRINTING"
    case DONE       = "DONE"
    case ERROR      = "ERROR"
    case UNKNOWN    = "UNKNOWN"
    case NOT_FOUND  = "NOT_FOUND"
}
