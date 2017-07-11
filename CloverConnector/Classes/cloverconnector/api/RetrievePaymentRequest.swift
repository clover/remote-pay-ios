//
//  RetrievePaymentRequest.swift
//  Pods
//
//
//

public class RetrievePaymentRequest {
    public var externalPayentId:String
    
    public init(_ externalPaymentId:String) {
        self.externalPayentId = externalPaymentId
    }
}
