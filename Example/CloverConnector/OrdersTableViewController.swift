//
//  OrdersViewController.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit

class OrdersTableViewController : UITableViewController, POSStoreListener {
    
    @IBOutlet var ordersTable: UITableView!
    
    override func viewDidLoad() {
        if let store = getStore() {
            store.addStoreListener(self)
        }
    }
    
    private func getStore() -> POSStore? {
        return (UIApplication.sharedApplication().delegate as? AppDelegate)?.store
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let store = getStore() {
            return store.orders.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "OrderTableCell") as! OrdersTableViewCell
        if let store = getStore() {
            
            if let order = store.orders.objectAtIndex((indexPath as NSIndexPath).row) as? POSOrder {
                cell.orderPriceLabel.text = "\(order.getTotal())"
                cell.orderNumberLabel.text = "\(order.orderNumber)"
            }
            
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    
    func newOrderCreated(_ order: POSOrder) {
        ordersTable.reloadData()
    }
    func preAuthAdded(_ payment:POSPayment) {
        
    }
    func preAuthRemoved(_ payment:POSPayment) {
        
    }
    func vaultCardAdded(_ card:POSCard) {
        
    }
    func manualRefundAdded(credit: POSNakedRefund) {
        
    }
}

class OrdersTableViewCell : UITableViewCell {
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var orderPriceLabel: UILabel!
    
}
