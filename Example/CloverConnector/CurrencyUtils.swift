//
//  CurrencyUtils.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

class CurrencyUtils {
    class func IntToFormat(value:Int, locale:NSLocale = NSLocale.currentLocale()) -> String? {
        let formatter:NSNumberFormatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = locale
        let price = Float(value) / 100

        return formatter.stringFromNumber(NSNumber(float: price))
    }
}
