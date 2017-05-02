//
//  OrderDetailsViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class OrderDetailsViewController : UIViewController {
    @IBOutlet weak var orderItemsTable: UITableView!
    @IBOutlet weak var orderPaymentsTable: UITableView!
    
    override func viewDidLoad() {
        
    }
}

class OrderItemsTableDelegate : UITableViewController {
    
    private var store:POSStore? {
        get {
            return ((UIApplication.sharedApplication().delegate as? AppDelegate)?.store)!
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let store = self.store {
            return store.orders.count
        }
        return 0
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OrderItemTableCell") as! OrdersTableViewCell
        if let store = self.store {
            
            if let order = store.orders.objectAtIndex((indexPath as NSIndexPath).row) as? POSOrder {
                cell.orderPriceLabel.text = "\(order.getTotal())"
                cell.orderNumberLabel.text = "\(order.orderNumber)"
            }
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}

class OrderPaymentsTableDelegate : UITableViewController {
    private var store:POSStore? {
        get {
            return ((UIApplication.sharedApplication().delegate as? AppDelegate)?.store)!
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
                cell.orderPriceLabel.text = "\(order.getTotal())"
                cell.orderNumberLabel.text = "\(order.orderNumber)"
            }
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
