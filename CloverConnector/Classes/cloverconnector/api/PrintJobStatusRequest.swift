//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//


import Foundation

public class PrintJobStatusRequest: NSObject {
    let printRequestId: String
    
    /// Create an object used to query the status of a print job via 'retreivePrintJobStatus()'
    ///
    /// - Parameter printRequestId: Identifier for a print job to be queried
    public init(_ printRequestId: String) {
        self.printRequestId = printRequestId
    }
    
    fileprivate override init() { self.printRequestId = String() }//marking as private to enforce object creation through another initializer 
}
