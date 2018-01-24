//
//  TestSupport.swift
//  CloverConnector_Example
//
//  Copyright © 2017 Clover Networks, Inc. All rights reserved.
//

import XCTest
@testable import CloverConnector
import ObjectMapper




/// This will run a series of tests (basically a deep compare of the objects).  In order to pass, all tests have to pass.
/// The test will first serialize the input, then deep compare the resulting object to the output.
/// The input will be mapped using the type of the output as the pattern to map to.
///
/// - Parameters:
///   - input: A JSON Representation of the object to be serialized.
///   - output: The BaseMappable object to compare the input to.
/// - Returns: True if all parameters of the resulting object are equal to the matching parameters in the output.
func runContentsTestDeserializationPass<T>(input:String,output:T) -> Bool where T : BaseMappable {
    guard let message = Mapper<T>().map(JSONString: input) else {
        print("Could not deserialize the message")
        return false
    }
    func testChildren(children:Mirror.Children) -> Bool {
        for outputProperty in children {
            guard let inputProperty = Mirror(reflecting: message).children.filter({$0.label == outputProperty.label}).first?.value ?? Mirror(reflecting: message).superclassMirror?.children.filter({$0.label == outputProperty.label}).first?.value else {
                print("Could not Match Property for Label \(outputProperty.label ?? "nil")")
                return false
            }
            guard let comp = compareAny(lhs: outputProperty.value, rhs: inputProperty) else {
                print("Could not Compare Any for Label \(outputProperty.label ?? "nil")")
                return false
            }
            if !comp {
                print("Comparison failed for \(outputProperty.label ?? "nil")")
                return false
            }
        }
        return true
    }
    
    if !testChildren(children: Mirror(reflecting: output).children) { return false }
    if let children = Mirror(reflecting: output).superclassMirror?.children {
        if !testChildren(children: children) { return false }
    }

    return true
}
/// Compares two Any objects for Equality.
/// Checks for the following types/cases:
///    nil (Any can be nil)
///    Int
///    String
///    Double
///    Method
///
/// - Parameters:
///   - lhs: Any object to compare
///   - rhs: Any object to compare
/// - Returns: True if the two objects are equal, False if they are not equal, and nil if equality cannot be determined.
func compareAny(lhs:Any,rhs:Any) -> Bool? {
    
//    print("lhs: \(lhs), rhs: \(rhs)")
    if isAnyNil(any: lhs) {
        return isAnyNil(any: rhs)
    } else {
        if isAnyNil(any: rhs) {
            return false
        }
    }
    
    if let lhsVal = lhs as? Int {
        if let rhsVal = rhs as? Int {
            return lhsVal == rhsVal
        }
    } else if let lhsVal = lhs as? String {
        if let rhsVal = rhs as? String {
            return lhsVal == rhsVal
        }
    } else if let lhsVal = lhs as? Double {
        if let rhsVal = rhs as? Double {
            return lhsVal == rhsVal
        }
    } else if let lhsVal = lhs as? CloverConnector.Method {
        if let rhsVal = rhs as? CloverConnector.Method {
            return lhsVal.rawValue == rhsVal.rawValue
        }
    }
    
    return nil
}

/// Tests two objects for equality when the type of one side is not yet known.
/// Attempts to cast the test value to the same type as the valid value, and performs an equality test.
/// Also checks for nil for each object.
///
/// - Parameters:
///   - test: The unknown object of type Any to test for equality
///   - valid: The known object of type T (Equatable) to test against
///   - pass: Whether the equality test should result in a true or a false outcome
/// - Returns: True if the equality test passes, false if it fails, and nil if the two objects are not equatable.
func objectTest<T>(test:Any,valid:T,pass:Bool) -> Bool? where T : Equatable {
    if isAnyNil(any: test) {
        return isAnyNil(any: valid)
    } else {
        if isAnyNil(any: valid) {
            return false
        }
    }
    
    guard let test = test as? T else {
        print("Types do not match")
        return nil
    }
    return pass ? test == valid : test != valid
}


/// Checks if an Any object is really nil
/// Any is technically a Protocol, not a type, and can therefore hold an Optional, despite not being defined as one.  This function checks for that case.
///
/// - Parameter any: Any... thing
/// - Returns: true if nil, false if not nil
func isAnyNil(any:Any) -> Bool {
    let mirror = Mirror(reflecting:any)
    return mirror.displayStyle == .optional && mirror.children.count == 0
}













/// Takes a BaseMappable object as input, maps that to a JSON String, then uses the JSONSerialization to map back to a JSON Dictionary, and finally compares the results to the passed in dictionary.
///
/// - Parameters:
///   - input: The object to test
///   - output: A dictionary containing the specific tests to run against the resulting dictionary
/// - Returns: True if all tests pass, False if any test fails
func runContentsTestSerialization<T>(input:T,output:[String:(test:Any?,pass:Bool)]) -> Bool where T : BaseMappable {
    guard let messageJSON = Mapper().toJSONString(input) else {
        print("Failed to map Object to JSON String")
        return false
    }
    guard let data = messageJSON.data(using: .utf8) else {
        print("Failed to write JSON String to Data")
        return false
    }
    guard let dictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any] else {
        print("Failed to parse Data to JSON Dictionary")
        return false
    }
    for thisTest in output {
        if let validAny = dictionary[thisTest.key],
            let validTest = thisTest.value.test {
            switch validAny {
            case let valid as Int:
                if let pass = objectTest(test: validTest, valid: valid, pass: thisTest.value.pass) {
                    if !pass { return false }
                } else { return false }
            case let valid as String:
                if let pass = objectTest(test: validTest, valid: valid, pass: thisTest.value.pass) {
                    if !pass { return false }
                } else { return false }
            default:
                print("Could not match a type for \(thisTest.key)")
                return false
            }
        } else {
            if thisTest.value.test == nil {
                if dictionary[thisTest.key] != nil { return false }
            } else {
                print("Missing value for key \(thisTest.key)")
                return false
            }
        }
    }
    return true
}





