//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import ObjectMapper

public class PaymentResponse : BaseResponse {

    /*
     * The payment from the sale
     */
    public var payment:CLVModels.Payments.Payment? // optional, because on Finish Cancel won't have a payment
    public var signature:Signature?

    public var isPreAuth:Bool {
        get {
            return payment?.cardTransaction?.type_ == CLVModels.Payments.CardTransactionType.PREAUTH && payment?.result == .AUTH
        }
    }
    
    public var isAuth:Bool {
        get {
            return payment?.cardTransaction?.type_ == CLVModels.Payments.CardTransactionType.PREAUTH && payment?.result == .SUCCESS

        }
    }

    public var isSale:Bool {
        get {
            return payment?.cardTransaction?.type_ == CLVModels.Payments.CardTransactionType.AUTH && payment?.result == .SUCCESS
        }
    }
    
    public init(success:Bool, result:ResultCode, payment:CLVModels.Payments.Payment? = nil, signature:Signature? = nil) {
        super.init(success:success, result:result)
        self.payment = payment
        self.signature = signature
    }
    
    required public init?(_ map: Map) {
        super.init(map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        payment <- map["payment"]
        signature <- map["signature"]
    }
}
