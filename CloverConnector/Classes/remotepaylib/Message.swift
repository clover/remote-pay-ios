//
//  Message.swift
//  CloverSDKRemotepay
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class Message : NSObject, Mappable {
    public fileprivate(set) var method:Method
    public var version:Int = 1
    
    public init(method:Method) {
        self.method = method
    }
    
    public required init?(map:Map) {
        method = Method.BREAK
    }
    
    public func mapping(map:Map) {
        method <- map["method"]
        version <- map["version"]
    }
    
    static let displayOrderTransform = TransformOf<DisplayOrder, String>(fromJSON: { (value: String?) -> DisplayOrder? in
        if let val = value {
            if let pi = Mapper<DisplayOrder>().map(JSONString: val) {
                return pi
            }
        }
        return nil
        }, toJSON: { (value: DisplayOrder?) -> String? in
            if let value = value,
                let valueJSON = Mapper().toJSONString(value, prettyPrint: false) {
                return String(valueJSON)
            }
            return nil
    })
    
    static let employeeTransform = TransformOf<CLVModels.Employees.Employee, String>(fromJSON: { (value: String?) -> CLVModels.Employees.Employee? in
        if let val = value {
            if let pi = Mapper<CLVModels.Employees.Employee>().map(JSONString: val) {
                return pi
            }
        }
        return nil
        }, toJSON: { (value: CLVModels.Employees.Employee?) -> String? in
            if let val = value {
                if let result = Mapper().toJSONString(val, prettyPrint:false) {
                    return String(result)
                }
            }
            return nil
    })


    static let orderTransform = TransformOf<CLVModels.Order.Order, String>(fromJSON: { (value: String?) -> CLVModels.Order.Order? in
        if let val = value {
            if let pi = Mapper<CLVModels.Order.Order>().map(JSONString: val) {
                return pi
            }
        }
        return nil
        }, toJSON: { (value: CLVModels.Order.Order?) -> String? in
            if let val = value {
                if let result = Mapper().toJSONString(val, prettyPrint:false) {
                    return String(result)
                }
            }
            return nil
    })
    
    static let paymentTransform = TransformOf<CLVModels.Payments.Payment, String>(fromJSON: { (value: String?) -> CLVModels.Payments.Payment? in
        if let val = value,
            let pi = Mapper<CLVModels.Payments.Payment>().map(JSONString: val) {
            return pi
        }
        return nil
        }, toJSON: { (obj: CLVModels.Payments.Payment?) -> String? in
            if obj != nil {
                if let val = obj,
                    let value = Mapper().toJSONString(val, prettyPrint:false) {
                    return String(value)
                }
            }
            return nil
    })
    
    static let printerTransform = TransformOf<CLVModels.Printer.Printer, String>(fromJSON: { (value: String?) -> CLVModels.Printer.Printer? in
        if let printerString = value, let printer = Mapper<CLVModels.Printer.Printer>().map(JSONString: printerString) {
            return printer
        }
        
        return nil
    }) { (obj: CLVModels.Printer.Printer?) -> String? in
        if let printerObj = obj, let printerString = Mapper().toJSONString(printerObj, prettyPrint: false) {
            return printerString
        }
        
        return nil
    }
    
    static let creditTransform = TransformOf<CLVModels.Payments.Credit, String>(fromJSON: { (value: String?) -> CLVModels.Payments.Credit? in
        
        if let val = value,
            let pi = Mapper<CLVModels.Payments.Credit>().map(JSONString: val) {
            return pi
        }
        return nil
        }, toJSON: { (obj: CLVModels.Payments.Credit?) -> String? in
            if obj != nil {
                if let val = obj,
                    let value = Mapper().toJSONString(val, prettyPrint:false) {
                    return String(value)
                }
            }
            return nil
    })
    
    static let refundTransform = TransformOf<CLVModels.Payments.Refund, String>(fromJSON: { (value: String?) -> CLVModels.Payments.Refund? in
        
        if let val = value,
            let pi = Mapper<CLVModels.Payments.Refund>().map(JSONString: val) {
            return pi
        }
        return nil
        }, toJSON: { (obj: CLVModels.Payments.Refund?) -> String? in
            if obj != nil {
                if let val = obj,
                    let value = Mapper().toJSONString(val, prettyPrint:false) {
                    return String(value)
                }
            }
            return nil
    })
    
    
    static let vaultedCardTransform = TransformOf<CLVModels.Payments.VaultedCard, String>(fromJSON: { (value: String?) -> CLVModels.Payments.VaultedCard? in
        
        if let val = value,
            let pi = Mapper<CLVModels.Payments.VaultedCard>().map(JSONString: val) {
            return pi
        }
        return nil
    }, toJSON: { (obj: CLVModels.Payments.VaultedCard?) -> String? in
        if obj != nil {
            if let val = obj,
                let value = Mapper().toJSONString(val, prettyPrint:false) {
                return String(value)
            }
        }
        return nil
    })
    
    static let pngBase64transform = TransformOf<[UInt8], String>(fromJSON: { (value: String?) -> [UInt8]? in
        if let val = value {
            return [UInt8](val.utf8)
        }
        return nil
        }, toJSON: { (value: [UInt8]?) -> String? in
            if let value = value {
                
                return String(bytes: value, encoding: String.Encoding.utf8)
            }
            return nil
    })
    
    static let uiStateTransform = TransformOf<UiState, String>(fromJSON: { (value: String?) -> UiState? in
        if let value = value {
            return UiState(rawValue: value)
        }
        return nil
        }, toJSON: { (value: UiState?) -> String? in
            return value?.rawValue
    })
    
    static let uiDirectionTransform = TransformOf<UiState.UiDirection, String>(fromJSON: { (value: String?) -> UiState.UiDirection? in
        if let value = value {
            return UiState.UiDirection(rawValue: value)
        }
        return nil
        }, toJSON: { (value: UiState.UiDirection?) -> String? in
            return value?.rawValue
    })
    
    static let methodTransform = TransformOf<Method, String>(fromJSON: { (value: String?) -> Method? in
        if let value = value {
            return Method(rawValue: value)
        }
        return nil
        }, toJSON: { (value: Method?) -> String? in
            return value?.rawValue
    })
    
    
    static let remoteMessageTypeTransform = TransformOf<RemoteMessageType, String>(fromJSON: { (value: String?) -> RemoteMessageType? in
        if let value = value {
            return RemoteMessageType(rawValue: value)
        }
        return nil
        }, toJSON: { (value: RemoteMessageType?) -> String? in
            return value?.rawValue
    })
}
