//
//  AvailableItemCollectionViewCell.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit

class AvailableItemCollectionViewCell:UICollectionViewCell {
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    
    var item:POSItem? {
        didSet(value) {
            if let item = item {
                itemName.text = item.name
                itemPrice.text = CurrencyUtils.IntToFormat(item.price)
            } else {
                itemName.text = "<Unknown>"
                itemPrice.text = "???"
            }
        }
    }
    
}
