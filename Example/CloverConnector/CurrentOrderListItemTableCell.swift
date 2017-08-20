//
//  CurrentOrderListItemTableCell.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit

class CurrentOrderListItemTableCell:UITableViewCell {
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var item:POSLineItem? {
        didSet(value) {
            if let item = item {
                if  let name = item.item.name {
                    quantityLabel.text = String(item.quantity)
                    itemLabel.text = name
                    priceLabel.text = CurrencyUtils.IntToFormat(item.item.price)
                }
            }
        }
    }

}
