//
//  VaultCardViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

public class VaultCardViewController:UIViewController, UITableViewDataSource
{
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate func getStore() -> POSStore? {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            return appDelegate.store
        }
        return nil
    }
    
    public override func viewDidLoad() {
    }
    
    deinit {
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        getStore()?.addStoreListener(self)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        getStore()?.removeStoreListener(self)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getStore()?.vaultedCards.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell:UITableViewCell = manualRefundsTable.dequeueReusableCellWithIdentifier(withIdentifier: "ManualRefundCell")
        
        var cell =  tableView.dequeueReusableCell(withIdentifier: "VCCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "VCCell")
        }
        
        if let vals = getStore()?.vaultedCards,
            indexPath.row < vals.count {
            
            let card = vals[indexPath.row]
            
            cell?.textLabel?.text = (card.first6) + "-XXXXXX-" + (card.last4)
            cell?.detailTextLabel?.text = card.token ?? "---"
        } else {
            cell?.textLabel?.text = "UNKNOWN"
            cell?.detailTextLabel?.text = ""
        }
        
        return cell ?? UITableViewCell()
    }
    
    @IBAction func onVaultCard(_ sender: UIButton) {
        tableView.becomeFirstResponder()
        (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector?.vaultCard(VaultCardRequest())
    }
}


extension VaultCardViewController : POSStoreListener {
    // POSStoreListener
    public func newOrderCreated(_ order:POSOrder){}
    public func preAuthAdded(_ payment:POSPayment){
    }
    public func preAuthRemoved(_ payment:POSPayment){}
    public func vaultCardAdded(_ card:POSCard){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            self.tableView.reloadData()
        })
    }
    public func manualRefundAdded(_ credit:POSNakedRefund){}
    // End POSStoreListener
}
