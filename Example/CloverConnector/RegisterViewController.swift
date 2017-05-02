//
//  RegisterViewController.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

class RegisterViewController:UIViewController, POSOrderListener, POSStoreListener, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var currentOrderListItems: UITableView!
    @IBOutlet weak var currentOrderView: UIView!
    @IBOutlet weak var storeView: UIView!
    var startingPoint:CGRect?
    private var store:POSStore?
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var discountsLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    private var signatureVerifyRequest:VerifySignatureRequest?
    
    @IBOutlet weak var currentOrderBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var currentOrderHeight: NSLayoutConstraint!
    @IBOutlet weak var storeViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var currentView: UIView!
    @IBOutlet var parentView: UIView!
    
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        store = (UIApplication.sharedApplication().delegate as! AppDelegate).store!
        ((UIApplication.sharedApplication()).delegate as! AppDelegate).cloverConnectorListener?.parentViewController = self
    
        let gesture = UITapGestureRecognizer(target: self, action: #selector(touchCurrentOrderView))
        currentOrderView.addGestureRecognizer(gesture);
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(panCurrentOrderView))
        currentOrderView.addGestureRecognizer(dragGesture)
        
        store?.addCurrentOrderListener(self)
        store?.addStoreListener(self)
        
        startingPoint = currentOrderView.frame
        
        //UILongPressGestureRecognizer(target: currentOrderListItems, action: #selector(handleLongPress))
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnectorListener?.viewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnectorListener?.viewController = self
    }
    
    @IBAction func longPressHandler(_ sender: UILongPressGestureRecognizer) {
        var cgPoint = sender.locationInView(self.currentOrderListItems)
        
        var indexPath = currentOrderListItems.indexPathForRowAtPoint(cgPoint)
        
        if indexPath == nil {
            // not on a row..
        } else if sender.state == UIGestureRecognizerState.Ended {
            if let data = store?.currentOrder?.items.objectAtIndex((indexPath! as NSIndexPath).row) as? POSLineItem {
                store?.currentOrder?.removeLineItem(data)
            }
        }
    }
    func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        var cgPoint = gestureRecognizer.locationInView(self.currentOrderListItems)
        
        var indexPath = currentOrderListItems.indexPathForRowAtPoint( cgPoint)
        
        if indexPath == nil {
            // not on a row..
        } else if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            if let data = store?.currentOrder?.items.objectAtIndex((indexPath! as NSIndexPath).row) as? POSLineItem {
                store?.currentOrder?.removeLineItem(data)
            }
        }
    }
    
    var startPan:CGPoint?
    var startOffset:CGFloat = 0.0

    func panCurrentOrderView(_ sender:UIPanGestureRecognizer) {
        
        
        //var p:CGPoint = currentOrderView.locationInView(parentView)
        var center:CGPoint = CGPoint.zero
        center = sender.locationInView(currentOrderView)
        
        
        switch sender.state {
        case .Began:
            Swift.print("began")
            startPan = sender.locationInView(currentOrderView)
            startOffset = self.storeViewTop.constant
            Swift.print("Starting at \(self.startPan!.x), \(self.startPan!.y)")
            //self.selectedView = view.hitTest(p, withEvent: nil)
            //if self.selectedView != nil {
            //    self.view.bringSubviewToFront(self.selectedView!)
        //}
        case .Changed:
            Swift.print("Changed..")
            Swift.print("Y-Offset: \(center.y-self.startPan!.y)")
            Swift.print("Center: \(self.startPan!.x), \(self.startPan!.y)")
            let yOffset = center.y-self.startPan!.y
            var currentConstant = self.storeViewTop.constant;
            currentConstant = yOffset + startOffset; // needs to be offset..
            if(currentConstant > self.parentView.frame.height) {
                currentConstant = self.parentView.frame.height
            }
            if(currentConstant < 120) {
                currentConstant = 120
            }
            
            self.storeViewTop.constant = currentConstant

            case .Ended:
                let lastOffset = self.storeViewTop.constant
                let halfWay = (self.parentView.frame.height - 120) / 2.0 + 120
                if(lastOffset < (halfWay)) {
                    // close
                    UIView.animateWithDuration( 0.1, animations: {
                        self.storeViewTop.constant = 120
                        self.currentOrderBottomOffset.constant = -500
                        self.parentView.layoutIfNeeded()
                        self.currentView.layoutIfNeeded()
                        
                        Swift.print("\(self.payButton.frame.minX) x \(self.payButton.frame.minY)")
                        Swift.print("\(self.currentOrderView.frame.height)")
                        
                        self.payButton.layoutIfNeeded()
                        self.currentView.layoutSubviews()
                        
                        }
                    );
                } else {
                    UIView.animateWithDuration( 0.1, animations: {
                        self.storeViewTop.constant = self.parentView.frame.height
                        self.currentOrderBottomOffset.constant = 0
                        self.parentView.layoutIfNeeded()
                        self.currentView.layoutIfNeeded()
                        
                        Swift.print("\(self.payButton.frame.minX) x \(self.payButton.frame.minY)")
                        Swift.print("\(self.currentOrderView.frame.height)")
                        
                        self.payButton.layoutIfNeeded()
                        self.currentView.layoutSubviews()
                        
                        }
                    );
            }
            case .Cancelled:
                Swift.print("cancelled")
            case .Failed:
                Swift.print("failed")
            default:
                Swift.print("Default")
        }
    }

    @objc func touchCurrentOrderView(_ sender:UITapGestureRecognizer) {
        if(true) {
            return
        }
        let orientation = UIApplication.sharedApplication().statusBarOrientation;
        if (orientation != UIInterfaceOrientation.Portrait && orientation != UIInterfaceOrientation.PortraitUpsideDown) {
            return;
        }

        
        if self.storeViewTop.constant == self.parentView.frame.height {
            
            UIView.animateWithDuration( 0.5, animations: {
                self.storeViewTop.constant = 120
                self.currentOrderBottomOffset.constant = -800
                self.parentView.layoutIfNeeded()
            });
        } else {
            startingPoint = currentOrderView.frame
            
            Swift.print("\(self.payButton.frame.minX) x \(self.payButton.frame.minY)")
            Swift.print("\(self.currentOrderView.frame.height)")
            
            UIView.animateWithDuration(0.5, animations: {
                self.storeViewTop.constant = self.parentView.frame.height
                self.currentOrderBottomOffset.constant = 0
                self.parentView.layoutIfNeeded()
                self.currentView.layoutIfNeeded()
                
                Swift.print("\(self.payButton.frame.minX) x \(self.payButton.frame.minY)")
                Swift.print("\(self.currentOrderView.frame.height)")
                
                self.payButton.layoutIfNeeded()
                self.currentView.layoutSubviews()
                
                }
            );
        }
        
    }
    
    var currentDisplayOrder:DisplayOrder = DisplayOrder()
    var itemsToDi = NSMutableDictionary()
    
    // POSOrderListener
    func itemAdded(_ item:POSLineItem) {
        updateTotals()
        
        let displayLineItem = DisplayLineItem(id:"\(arc4random())", name:item.item.name!, price: "\(CurrencyUtils.IntToFormat(item.item.price)!)", quantity: "\(item.quantity)")
        currentDisplayOrder.lineItems.append(displayLineItem)
        itemsToDi.setObject(displayLineItem, forKey: item.item.id as NSCopying)

        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.showDisplayOrder(currentDisplayOrder)
    }
    func itemRemoved(_ item:POSLineItem) {
        updateTotals()
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.showDisplayOrder(currentDisplayOrder)
    }
    func itemModified(_ item:POSLineItem) {
        updateTotals()
        if let displayLineItem = itemsToDi.objectForKey(item.item.id) as? DisplayLineItem {
            displayLineItem.quantity = "\(item.quantity)"
            displayLineItem.name = item.item.name
            displayLineItem.price = "\(CurrencyUtils.IntToFormat(item.item.price)!)"
        }
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.showDisplayOrder(currentDisplayOrder)

    }
    func discountAdded(_ item:POSDiscount) {
        updateTotals()
    }
    func paymentAdded(_ item:POSPayment) {
        updateTotals()
    }
    func refundAdded(_ refund: POSRefund) {
        updateTotals()
    }
    func paymentChanged(_ item:POSPayment) {
        updateTotals()
    }
    // POSOrderListener.End
    
    // POSStoreListener
    func newOrderCreated(_ order:POSOrder) {
        updateTotals()
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.removeDisplayOrder(currentDisplayOrder)
        currentDisplayOrder = DisplayOrder()
        currentDisplayOrder.id = "\(arc4random())"
        itemsToDi = NSMutableDictionary()
        
    }
    
    func preAuthAdded(_ payment: POSPayment) {
        // not needed in register
    }
    
    func preAuthRemoved(_ payment: POSPayment) {
        // not needed in register
    }
    
    func vaultCardAdded(_ card: POSCard) {
        // not needed in register
    }
    
    func manualRefundAdded(credit: POSNakedRefund) {
        // not needed in register
    }
    // POSStoreListener.End
    
    
    func updateTotals() {
        if let store = store,
            let currentOrder = store.currentOrder
        {
            subTotalLabel.text = CurrencyUtils.IntToFormat(currentOrder.getSubtotal())
            taxLabel.text = CurrencyUtils.IntToFormat(currentOrder.getTaxAmount())
            totalLabel.text = CurrencyUtils.IntToFormat(currentOrder.getTotal())
        }
        
        currentOrderListItems.reloadData()
        
        
        // update DisplayOrder..
        if let total = store?.currentOrder?.getTotal() {
            currentDisplayOrder.total = "\(CurrencyUtils.IntToFormat(total)!)"
        }
        if let sub = store?.currentOrder?.getSubtotal() {
            currentDisplayOrder.subtotal = "\(CurrencyUtils.IntToFormat(sub)!)"
        }
        if let tax = store?.currentOrder?.getTaxAmount() {
            currentDisplayOrder.tax = "\(CurrencyUtils.IntToFormat(tax)!)"
        }
    }
    
    // TableView
    
    
    func tableView(tv: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let store = store,
            let currentOrder = store.currentOrder {
            let data = currentOrder.items.objectAtIndex((indexPath as NSIndexPath).row) as? POSLineItem
            
            if let cell:CurrentOrderListItemTableCell = tv.dequeueReusableCellWithIdentifier( "OrderItemCell", forIndexPath: indexPath) as? CurrentOrderListItemTableCell,
                let data = data
            {
                cell.item = data
                return cell
            }
        }

        return tv.dequeueReusableCellWithIdentifier( "OrderItemCell", forIndexPath: indexPath)

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let store = store,
            let currentOrder = store.currentOrder {
            return currentOrder.items.count;
        }
        return 0;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    // Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (store?.availableItems.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier( "AvailableItemCell", forIndexPath: indexPath)
        
        if let store = store,
            let cell = cell as? AvailableItemCollectionViewCell {
            if let posItem:POSItem = store.availableItems.objectAtIndex((indexPath as NSIndexPath).row) as? POSItem {
                cell.item = posItem
            }
        }
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let store = store {
            if let item:POSItem = store.availableItems.objectAtIndex((indexPath as NSIndexPath).row) as? POSItem {
                store.currentOrder?.addLineItem(POSLineItem(item: item))
                //currentOrderListItems.reloadData()
            }
        }
    }
    

    /*func collectionView(_:layout:sizeForItemAtIndexPath:NSIndexPath) {
    
    }*/
    
    func verifySignature(_ signatureVerifyRequest:VerifySignatureRequest) {
        self.signatureVerifyRequest = signatureVerifyRequest
        self.performSegueWithIdentifier( "ShowSignature", sender: self)
//        ivc.showViewController(SignatureViewController(), sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        (segue.destinationViewController as? SignatureViewController)?.signatureVerifyRequest = self.signatureVerifyRequest
    }
    
    @IBAction func saleButtonClicked(_ sender: UIButton) {
        
        if let currentOrder = store?.currentOrder {
            let sr = SaleRequest(amount:currentOrder.getTotal(), externalId: "\(arc4random())")
            sr.tipAmount = nil
            sr.tippableAmount = currentOrder.getTippableAmount()
            sr.disablePrinting = true
            
            (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.sale(sr)
        }
    }
    @IBAction func authButtonClicked(_ sender: UIButton) {
        
        if let currentOrder = store?.currentOrder {
            let ar = AuthRequest(amount: currentOrder.getTotal(), externalId: "\(arc4random())")
            ar.tippableAmount = currentOrder.getTippableAmount()
            
            (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.auth(ar)
        }
    }
    @IBAction func newOrderButtonClicked(_ sender: UIButton) {
        if let store = store {
            store.newOrder()
        }
    }
}
