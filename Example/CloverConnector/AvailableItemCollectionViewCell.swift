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
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        quantityView.layer.cornerRadius = 15
    }
    
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
