//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//
import ObjectMapper

/**
 response to a capturePreAuth request
 */
public class CapturePreAuthResponse : BaseResponse {

    /// id of the pre-auth payment being captured
    public fileprivate(set) var paymentId:String?
    /// the base amount of the capture
    public fileprivate(set) var amount:Int?
    /// additional tip amount for the capture
    public fileprivate(set) var tipAmount:Int?

    public init(success:Bool, result:ResultCode, paymentId:String?, amount:Int?, tipAmount:Int?) {
        super.init(success: success, result:result)
        self.paymentId = paymentId
        self.amount = amount
        self.tipAmount = tipAmount
    }

    /// :nodoc:
    required public init?(map:Map) {
        super.init(map: map)
    }
    /// :nodoc:
    public override func mapping(map:Map) {
        super.mapping(map: map)
        paymentId <- map["paymentId"]
        amount <- map["amount"]
        tipAmount <- map["tipAmount"]
    }
}
