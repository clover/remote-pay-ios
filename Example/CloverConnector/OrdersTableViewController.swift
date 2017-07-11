//
//  OrdersViewController.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

class OrdersTableViewController : UITableViewController, POSStoreListener {
    
    @IBOutlet var ordersTable: UITableView!
    
    weak var selOrder:POSOrder?
    
    private var items:[(type: ITEM_TYPE, data: AnyObject)] {
        get {
            var _items:[(type: ITEM_TYPE, data: AnyObject)] = []
            if let orders = self.store?.orders {
                for var o in orders {
                    if (o as! POSOrder).status != .READY {
                        _items.append((type: .ORDER, data: o))
                        
                        if selOrder != nil && selOrder! === o {
                            if let payments = selOrder?.payments {
                                for var p in payments {
                                    _items.append((type: .PAYMENT, data: p))
                                }
                            }
                            /*if let items = selOrder?.items {
                             for var i in items {
                             _items.append((type: .ITEM, data: i))
                             }
                             }*/
                        }
                    }
                }
            }
            return _items
        }
    }
    
    private enum ITEM_TYPE {
        case ORDER
//        case ITEM
        case PAYMENT
    }
    

    
    override func viewDidLoad() {
        if let store = self.store {
            store.addStoreListener(self)
            selOrder = store.orders.lastObject as? POSOrder
        }
        
    }
    
    private var store:POSStore? {
        return (UIApplication.sharedApplication().delegate as? AppDelegate)?.store
    }
    
    private var cloverConnector:ICloverConnector? {
        get {
            return (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        switch item.type {
            case .ORDER:
                let order = item.data as! POSOrder
                let cell = tableView.dequeueReusableCellWithIdentifier( "OrderTableCell") as! OrdersTableViewCell
                
                cell.orderPriceLabel.text = "\(CurrencyUtils.IntToFormat(order.getTotal() ?? 0) ?? CurrencyUtils.IntToFormat(0)!)"
                cell.orderNumberLabel.text = "\(order.orderNumber)"
                cell.orderStatusLabel.text = "\(order.status ?? .UNKNOWN)"
                cell.orderDateLabel.text = "\(order.date)"
                return cell
            case .PAYMENT:
                let payment = item.data as! POSPayment
                let cell = tableView.dequeueReusableCellWithIdentifier( "OrderTablePaymentCell") as! OrdersTablePaymentViewCell
                
                cell.paymentPriceLabel.text = "\(CurrencyUtils.IntToFormat(payment.amount ?? 0) ?? CurrencyUtils.IntToFormat(0)!)"
                cell.paymentExternalIdLabel.text = "\(payment.externalPaymentId ?? "")"
                cell.paymentStatusLabel.text = "\(payment.status)"
                cell.paymentTipLabel.text = "\(CurrencyUtils.IntToFormat(payment.tipAmount ?? 0) ?? CurrencyUtils.IntToFormat(0)!)"
                return cell
//            case .ITEM:
//                let cell = tableView.dequeueReusableCellWithIdentifier( "OrderTableItemCell") as! OrdersTableItemViewCell
            
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selItem = items[indexPath.row]
        if selItem.type == .ORDER {
            selOrder = selItem.data as! POSOrder
            tableView.reloadData()
        } else if selItem.type == .PAYMENT {
            debugPrint("selected payment")
            // options? tip, void, refund
            let payment = selItem.data as! POSPayment
            
            if payment.status != .VOIDED {
                
                let uvc = UIAlertController(title: "Modify Payment", message: "", preferredStyle: .Alert)
                
                uvc.addAction(UIAlertAction(title: "Void", style: .Default, handler: { (aa) in
                    uvc.dismissViewControllerAnimated(true, completion: nil)
                    let vpr = VoidPaymentRequest(orderId: payment.orderId, paymentId: payment.paymentId, voidReason: .USER_CANCEL)
                    self.cloverConnector?.voidPayment(vpr)
                    
                }))
                uvc.addAction(UIAlertAction(title: "Refund", style: .Default, handler: { (aa) in
                    
                    
                    let fullRefundAC = UIAlertController(title: "Refund Payment", message: "", preferredStyle: .Alert)
                    fullRefundAC.addAction(UIAlertAction(title: "Full", style: .Default, handler: { (aa) in
                        let rpr = RefundPaymentRequest(orderId: payment.orderId, paymentId: payment.paymentId, fullRefund: true)
                        self.cloverConnector?.refundPayment(rpr)
                    }))
                    fullRefundAC.addAction(UIAlertAction(title: "Partial", style: .Cancel, handler: { (aa) in
                        let rpr = RefundPaymentRequest(orderId: payment.orderId, paymentId: payment.paymentId, amount: payment.amount / 2)
                        self.cloverConnector?.refundPayment(rpr)
                    }))
                    self.presentViewController(fullRefundAC, animated: true, completion: nil)
                }))
                if payment.status == .AUTHORIZED {
                    uvc.addAction(UIAlertAction(title: "Add Tip", style: .Default, handler: { (aa) in
                        //
                        //uvc.dismissViewControllerAnimated(false, completion: {
                        debugPrint("Add tip dismissed")
                        let tipCtrl = UIAlertController(title: "Add Tip", message: "enter amount", preferredStyle: .Alert)
                        tipCtrl.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
                            textField.placeholder = "Enter Tip Amount"
                        }
                        tipCtrl.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (aa) in
                            let tipAmountTextField = tipCtrl.textFields![0] as UITextField
                            if let amt = Int(tipAmountTextField.text ?? "0") {
                                if amt > 0 {
                                    let tipAdjust = TipAdjustAuthRequest(orderId: payment.orderId, paymentId: payment.paymentId, tipAmount: amt)
                                    self.cloverConnector?.tipAdjustAuth(tipAdjust)
                                }
                            }
                            
                        }))
                        self.presentViewController(tipCtrl, animated: true, completion: nil)
                        //                    })
                    }))
                }
                uvc.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (aa) in
                    //                uvc.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(uvc, animated: true, completion: nil)
                //        } else if selItem.type == .ITEM {
                //            debugPrint("selected item")
            } else {
                // do nothing...it is voided
            }
            
        } else {
            debugPrint("unknown type selected")
        }
        
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        // show order items...
        selOrder = items[indexPath.row].data as? POSOrder
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let orderDetails = segue.destinationViewController as! OrderDetailsViewController
        
        if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
            orderDetails.selOrder = items[indexPath.row].data as? POSOrder
        }
        
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
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    
}

class OrdersTablePaymentViewCell : UITableViewCell {
    @IBOutlet weak var paymentStatusLabel: UILabel!
    @IBOutlet weak var paymentExternalIdLabel: UILabel!
    @IBOutlet weak var paymentPriceLabel: UILabel!
    @IBOutlet weak var paymentTipLabel: UILabel!
    
}

class OrdersTableItemViewCell : UITableViewCell {
    
}
