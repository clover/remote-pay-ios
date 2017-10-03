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

class OrdersTableViewController : UITableViewController, POSStoreListener, POSOrderListener {
    
    @IBOutlet var ordersTable: UITableView!
    
    weak var selOrder:POSOrder?
    
    fileprivate var items:[(type: ITEM_TYPE, data: AnyObject)] {
        get {
            var _items:[(type: ITEM_TYPE, data: AnyObject)] = []
            if let orders = self.store?.orders {
                for o in orders {
                    if (o ).status != .READY {
                        _items.append((type: .order, data: o))
                        
                        if selOrder != nil && selOrder! === o {
                            if let payments = selOrder?.payments {
                                for p in payments {
                                    _items.append((type: .payment, data: p))
                                }
                            }
                            if let refunds = selOrder?.refunds {
                                for r in refunds {
                                    _items.append((type: .refund, data: r))
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
    
    fileprivate enum ITEM_TYPE {
        case order
//        case ITEM
        case payment
        case refund
    }
    

    
    override func viewDidLoad() {
        if let store = self.store {
            store.addStoreListener(self)
            store.addCurrentOrderListener(self)
            selOrder = store.orders.last
        }
        
    }
    
    fileprivate var store:POSStore? {
        return (UIApplication.shared.delegate as? AppDelegate)?.store
    }
    
    fileprivate var cloverConnector:ICloverConnector? {
        get {
            return (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        switch item.type {
            case .order:
                guard let order = item.data as? POSOrder,
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableCell") as? OrdersTableViewCell else { return UITableViewCell() }
                
                cell.orderPriceLabel.text = (CurrencyUtils.IntToFormat(order.getTotal()) ?? CurrencyUtils.FormatZero())
                cell.orderNumberLabel.text = String(order.orderNumber)
                cell.orderStatusLabel.text = order.status.rawValue
                cell.orderDateLabel.text = String(describing: order.date)
                return cell
            case .payment:
                guard let payment = item.data as? POSPayment,
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTablePaymentCell") as? OrdersTablePaymentViewCell else { return UITableViewCell() }
                
                cell.paymentPriceLabel.text = CurrencyUtils.IntToFormat(payment.amount) ?? CurrencyUtils.FormatZero()
                cell.paymentExternalIdLabel.text = payment.externalPaymentId ?? ""
                cell.paymentStatusLabel.text = payment.status.rawValue
                cell.paymentTipLabel.text = CurrencyUtils.IntToFormat(payment.tipAmount ?? 0) ?? CurrencyUtils.FormatZero()
                return cell
        case .refund:
            guard let refund = item.data as? POSRefund,
                let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTablePaymentCell") as? OrdersTablePaymentViewCell else { return UITableViewCell() }
            
            cell.paymentPriceLabel.text = CurrencyUtils.IntToFormat(refund.amount) ?? CurrencyUtils.FormatZero()
            cell.paymentExternalIdLabel.text = "REFUND"
            cell.paymentStatusLabel.text = ""
            cell.paymentTipLabel.text = ""
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selItem = items[indexPath.row]
        if selItem.type == .order {
            selOrder = selItem.data as? POSOrder
            tableView.reloadData()
        } else if selItem.type == .payment {
            debugPrint("selected payment")
            // options? tip, void, refund
            guard let payment = selItem.data as? POSPayment else { return }
            
            if payment.status != .VOIDED {
                
                let uvc = UIAlertController(title: "Modify Payment", message: "", preferredStyle: .alert)
                
                uvc.addAction(UIAlertAction(title: "Void", style: .default, handler: { (aa) in
                    uvc.dismiss(animated: true, completion: nil)
                    let vpr = VoidPaymentRequest(orderId: payment.orderId, paymentId: payment.paymentId, voidReason: .USER_CANCEL)
                    self.cloverConnector?.voidPayment(vpr)
                    
                }))
                uvc.addAction(UIAlertAction(title: "Refund", style: .default, handler: { (aa) in
                    
                    let fullRefundAC = UIAlertController(title: "Refund Payment", message: "", preferredStyle: .alert)
                    fullRefundAC.addAction(UIAlertAction(title: "Full", style: .default, handler: { (aa) in
                        let rpr = RefundPaymentRequest(orderId: payment.orderId, paymentId: payment.paymentId, fullRefund: true)
                        self.cloverConnector?.refundPayment(rpr)
                    }))
                    fullRefundAC.addAction(UIAlertAction(title: "Partial", style: .cancel, handler: { (aa) in
                        let rpr = RefundPaymentRequest(orderId: payment.orderId, paymentId: payment.paymentId, amount: payment.amount / 2)
                        self.cloverConnector?.refundPayment(rpr)
                    }))
                    self.present(fullRefundAC, animated: true, completion: nil)
                }))
                if payment.status == .AUTHORIZED {
                    uvc.addAction(UIAlertAction(title: "Add Tip", style: .default, handler: { (aa) in
                        debugPrint("Add tip dismissed")
                        let tipCtrl = UIAlertController(title: "Add Tip", message: "enter amount", preferredStyle: .alert)
                        tipCtrl.addTextField { textField in
                            textField.placeholder = "Enter Tip Amount"
                        }
                        tipCtrl.addAction(UIAlertAction(title: "Done", style: .default, handler: { (aa) in
                            guard let tipAmountText = tipCtrl.textFields?.first?.text,
                                let tipAmount = Int(tipAmountText) else { return }
                            if tipAmount > 0 {
                                let tipAdjust = TipAdjustAuthRequest(orderId: payment.orderId, paymentId: payment.paymentId, tipAmount: tipAmount)
                                self.cloverConnector?.tipAdjustAuth(tipAdjust)
                            }
                        }))
                        self.present(tipCtrl, animated: true, completion: nil)
                    }))
                }
                uvc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (aa) in
                }))
                self.present(uvc, animated: true, completion: nil)
            } else {
                // do nothing...it is voided
            }
        } else if selItem.type == .refund {
            // do nothing extra
        } else {
            debugPrint("unknown type selected")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // show order items...
        selOrder = items[indexPath.row].data as? POSOrder
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let orderDetails = segue.destination as? OrderDetailsViewController,
            let sender = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: sender ) else { return }
        orderDetails.selOrder = items[indexPath.row].data as? POSOrder
    }

    
    // MARK: - Store Listener
    func newOrderCreated(_ order: POSOrder) {
        DispatchQueue.main.async { [weak self] in
            self?.ordersTable.reloadData()
        }
    }
    func preAuthAdded(_ payment:POSPayment) {
        
    }
    func preAuthRemoved(_ payment:POSPayment) {
        
    }
    func vaultCardAdded(_ card:POSCard) {
        
    }
    func manualRefundAdded(_ credit: POSNakedRefund) {
        
    }

    // MARK: - Order Listener
    func itemAdded(_ item:POSLineItem) {
        
    }
    func itemRemoved(_ item:POSLineItem) {
        
    }
    func itemModified(_ item:POSLineItem) {
        
    }
    func discountAdded(_ item:POSDiscount) {
        
    }
    func paymentAdded(_ item:POSPayment) {
        
    }
    func refundAdded(_ refund:POSRefund) {
        DispatchQueue.main.async { [weak self] in
            self?.ordersTable.reloadData()
        }
    }
    func paymentChanged(_ item:POSPayment) {
        
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
