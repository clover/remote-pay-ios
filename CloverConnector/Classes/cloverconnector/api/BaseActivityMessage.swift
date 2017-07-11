//
//  BaseActivityMessage.swift
//  Pods
//
//
//

public class BaseActivityMessage:NSObject {
    public init(action a:String, payload p:String? = nil) {
        self.action = a
        self.payload = p
    }
    public var action:String = ""
    public var payload:String?
}
