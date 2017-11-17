//
//  OrderDetailsViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit

class OrderDetailsViewController : UITableViewController {
    @IBOutlet weak var orderItemsTable: UITableView!
    @IBOutlet weak var orderPaymentsTable: UITableView!
    
    weak var selOrder:POSOrder?
    
    override func viewDidLoad() {
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        self.navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selOrder?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: "OrderItemCell") as? OrderItemCell
        if let item = selOrder?.items[indexPath.row]{
            cell?.orderItemQuantity.text = String(item.quantity)
            cell?.orderItemDescription.text = item.item.name ?? "Unknown"
            cell?.orderItemPrice.text = CurrencyUtils.IntToFormat(item.item.price) ?? CurrencyUtils.FormatZero()
        }
        return cell ?? UITableViewCell()
    }
}

class OrderItemCell : UITableViewCell {
    @IBOutlet weak var orderItemQuantity: UILabel!
    @IBOutlet weak var orderItemDescription: UILabel!
    @IBOutlet weak var orderItemPrice: UILabel!
    
}

/*class OrderItemsTableDelegate : UITableViewController {
    
    
    
    private var items:[(type: ITEM_TYPE, data: AnyObject)] {
        get {
            var _items:[(type: ITEM_TYPE, data: AnyObject)] = []
            if let orders = store?.orders {
                for var o in orders {
                    _items.append((type: .ORDER, data: o))
                    
                    if selOrder != nil && selOrder! === o {
                        if let payments = selOrder?.payments {
                            for var p in payments {
                                _items.append((type: .PAYMENT, data: p))
                            }
                        }
                        if let items = selOrder?.items {
                            for var i in items {
                                _items.append((type: .ITEM, data: i))
                            }
                        }
                    }
                }
            }
            return _items
        }
    }
    
    private enum ITEM_TYPE {
        case ORDER
        case ITEM
        case PAYMENT
    }
    
    private var store:POSStore? {
        get {
            return ((UIApplication.shared.delegate as? AppDelegate)?.store)!
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let store = self.store {
            return items.count
        }
        return 0
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OrderItemTableCell") as! OrdersTableViewCell
        if let store = self.store {
            
            if let order = store.orders.objectAtIndex((indexPath as NSIndexPath).row) as? POSOrder {
                cell.orderPriceLabel.text =  order.getTotal()
                cell.orderNumberLabel.text = order.orderNumber
            }
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selItem = items[indexPath.row]
        if selItem.type == .ORDER {
            selOrder = selItem.data as! POSOrder
            tableView.reloadData()
        } else if selItem.type == .PAYMENT {
            debugPrint("selected payment")
        } else if selItem.type == .ITEM {
            debugPrint("selected item")
        } else {
            debugPrint("unknown type selected")
        }

    }
    
}*/

/*class OrderPaymentsTableDelegate : UITableViewController {
    private var store:POSStore? {
        get {
            return ((UIApplication.shared.delegate as? AppDelegate)?.store)!
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let store = self.store {
            return store.orders.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "OrderPaymentTableCell") as! OrdersTableViewCell
        if let store = self.store {
            
            if let order = store.orders.objectAtIndex((indexPath as NSIndexPath).row) as? POSOrder {
                cell.orderPriceLabel.text = order.getTotal()
                cell.orderNumberLabel.text = order.orderNumber
            }
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}*/
