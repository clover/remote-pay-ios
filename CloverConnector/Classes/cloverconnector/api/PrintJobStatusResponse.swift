//
//  PrintJobStatusResponse.swift
//  Pods
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

public class PrintJobStatusResponse: NSObject {
    public fileprivate(set) var printRequestId: String?
    public fileprivate(set) var status: PrintJobStatus
    
    init(_ printRequestId: String?, status: String?) {
        self.printRequestId = printRequestId
        
        guard let status = status else {
            self.status = .ERROR
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
