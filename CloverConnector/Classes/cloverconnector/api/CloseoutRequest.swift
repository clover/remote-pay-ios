//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper



public class CloseoutRequest : NSObject {

  /**
  * Identifier for the request
   */
  var requestId:String? = nil 
  /**
  * Allow closeout if there are open tabs
   */
  var allowOpenTabs:Bool = false
    /// :nodoc:
  var batchId:String?
    /// :nodoc:
  var id:String? = nil 

    public init(allowOpenTabs:Bool, batchId:String?) {
        self.allowOpenTabs = allowOpenTabs
        self.batchId = batchId
    }

}

