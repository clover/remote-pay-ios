//
//  MiscViewController.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import Foundation
import UIKit
import CloverConnector

class MiscViewController : UIViewController {
    @IBOutlet weak var customActivityPayload: UITextField!
    @IBOutlet weak var customActivityAction: UITextField!
    @IBOutlet weak var nonBlockingSwitch: UISwitch!
    @IBOutlet weak var externalPaymentId: UITextField!
    @IBOutlet weak var sendMsgWithStatusSwitch: UISwitch!
        
    @IBAction func welcomeClicked(_ sender: UIButton) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.showWelcomeScreen()
    }
    @IBAction func thankYouClicked(_ sender: UIButton) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.showThankYouScreen()
    }
    @IBAction func showMessageClicked(_ sender: UIButton) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.showMessage("Hello iOS!")
    }
    @IBAction func resetClicked(_ sender: UIButton) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.resetDevice()
    }
    @IBAction func readCardData(_ sender: UIButton) {
        let request:ReadCardDataRequest = ReadCardDataRequest()
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.readCardData(request);
    }
    @IBAction func requestPendingPayments(_ sender: UIButton) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.retrievePendingPayments()
    }
    @IBAction func printImage(_ sender: UIButton) {
//        let logo = UIImage(named: "#imageLiteral(resourceName: "clover_horizontal")")
        if let img = UIImage(named: "Clover Logo") {// UIImage(contentsOfFile: "Clover Logo") {
            (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.printImage(img)
        } else {
            debugPrint("Error loading image")
        }
//        let img = UIImage(contentsOfFile: #imageLiteral(resourceName: "Clover Logo"))
    }
    @IBAction func startCustomActivity(_ sender: UIButton) {
        let car = CustomActivityRequest(customActivityAction.text ?? "unk", payload: customActivityPayload.text)
        car.nonBlocking = nonBlockingSwitch.on
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.startCustomActivity(car)
    }
    @IBAction func sendMessageClicked(_ sender: UIButton) {
        let mta = MessageToActivity(action: customActivityAction.text ?? "unk", payload: customActivityPayload.text)
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.sendMessageToActivity(mta)
    }
    @IBAction func currentStatusClicked(sender: UIButton) {
        let dsr = RetrieveDeviceStatusRequest(sendLastMessage: sendMsgWithStatusSwitch.on)
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.retrieveDeviceStatus(dsr)
    }
    @IBAction func queryPayment(sender: UIButton) {
        guard let epi = externalPaymentId.text else {
            debugPrint("Invalid external Id")
            return
        }
        let rpr = RetrievePaymentRequest(epi)
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.retrievePayment(rpr)
    }
    
}
