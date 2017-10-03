//
//  CurrencyUtils.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation

class CurrencyUtils {
    class func IntToFormat(_ value:Int, locale:Locale = Locale.current) -> String? {
        let formatter:NumberFormatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        let price = Float(value) / 100

        return formatter.string(from: NSNumber(value: price as Float))
    }
    class func FormatZero() -> String {
        return CurrencyUtils.IntToFormat(0)!
    }
}
