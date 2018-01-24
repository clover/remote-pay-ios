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

class MiscViewController : UIViewController, UINavigationControllerDelegate {
    @IBOutlet var customActivityPayload: UITextField!
    @IBOutlet var customActivityAction: UITextField!
    @IBOutlet var nonBlockingSwitch: UISwitch!
    @IBOutlet var externalPaymentId: UITextField!
    @IBOutlet var sendMsgWithStatusSwitch: UISwitch!
    
    var appDelegate: AppDelegate? {
        get {
            return UIApplication.shared.delegate as? AppDelegate
        }
    }
    
    @IBAction func welcomeClicked(_ sender: UIButton) {
        appDelegate?.cloverConnector?.showWelcomeScreen()
    }
    
    @IBAction func thankYouClicked(_ sender: UIButton) {
        appDelegate?.cloverConnector?.showThankYouScreen()
    }
    
    @IBAction func showMessageClicked(_ sender: UIButton) {
        appDelegate?.cloverConnector?.showMessage("Hello iOS!")
    }
    
    @IBAction func resetClicked(_ sender: UIButton) {
        appDelegate?.cloverConnector?.resetDevice()
    }
    
    @IBAction func readCardData(_ sender: UIButton) {
        let request:ReadCardDataRequest = ReadCardDataRequest()
        appDelegate?.cloverConnector?.readCardData(request);
    }
    
    @IBAction func openCashDrawer(_ sender: UIButton) {
        let cashDrawerRequest = OpenCashDrawerRequest("Cash Back", deviceId: nil)
        appDelegate?.cloverConnector?.openCashDrawer(cashDrawerRequest)
    }
    
    @IBAction func requestPendingPayments(_ sender: UIButton) {
        appDelegate?.cloverConnector?.retrievePendingPayments()
    }
    
    @IBAction func startCustomActivity(_ sender: UIButton) {
        let car = CustomActivityRequest(customActivityAction.text ?? "unk", payload: customActivityPayload.text)
        car.nonBlocking = nonBlockingSwitch.isOn
        appDelegate?.cloverConnector?.startCustomActivity(car)
    }
    
    @IBAction func sendMessageClicked(_ sender: UIButton) {
        let mta = MessageToActivity(action: customActivityAction.text ?? "unk", payload: customActivityPayload.text)
        appDelegate?.cloverConnector?.sendMessageToActivity(mta)
    }
    
    @IBAction func currentStatusClicked(_ sender: UIButton) {
        let dsr = RetrieveDeviceStatusRequest(sendLastMessage: sendMsgWithStatusSwitch.isOn)
        appDelegate?.cloverConnector?.retrieveDeviceStatus(dsr)
    }
    
    @IBAction func queryPayment(_ sender: UIButton) {
        guard let epi = externalPaymentId.text else {
            debugPrint("Invalid external Id")
            return
        }
        let rpr = RetrievePaymentRequest(epi)
        appDelegate?.cloverConnector?.retrievePayment(rpr)
    }
}
