//
//  PrintTestViewController.swift
//  CloverConnector
//
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import UIKit
import Foundation
import CloverConnector

class PrintTestViewController: UIViewController {
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var printTextButton: UIButton!
    @IBOutlet var printImageButton: UIButton!
    @IBOutlet var printURLButton: UIButton!
    @IBOutlet var urlTF: UITextField!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var printerTableView: UITableView!
    
    var selectedIndexPath: NSIndexPath?
    var selectedPrinter: CLVModels.Printer.Printer? {
        if let index = self.printerTableView.indexPathForSelectedRow?.row {
            return self.printers?.optionalElement(index)
        }
        
        return nil
    }
    
    var appDelegate: AppDelegate? {
        get {
            return UIApplication.sharedApplication().delegate as? AppDelegate
        }
    }
    
    var uniquePrintId: String {
        get {
            return String(arc4random())
        }
    }
    
    var printers: [CLVModels.Printer.Printer]?
    let reuseIdentifier = "PrinterCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         In the event that the UI is "compact" (such as for an iPhone), the tabBarController will show a "more" option for extra tabs.
         The "more" tab is a tableView containing the tabs that wouldn't otherwise fit on the tabBar. This includes a UINavigationController
         for subsequently shown UIViewControllers that allows the user to navigate back from a full-screen, modally presented view. On an regular
         width UI (iPad) however, there is enough width and the navigation controller isn't employed. As a result, we add a close button to allow
         the user to dismiss this view. Without it, the user would be stuck on this view without access to a nav bar or the tab bar.
         */
        if self.tabBarController?.moreNavigationController != nil {
            self.closeButton.hidden = true
        } else {
            self.closeButton.hidden = false
        }
        
        //delegation handled in extension
        printerTableView.delegate = self
        printerTableView.dataSource = self
        
        //fetch the accessible printers
        spinner.startAnimating()
        retrievePrinters { [weak self] (response) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.spinner.stopAnimating()
                self?.printers = response.printers
                self?.printerTableView.reloadData()
            })
        }
    }
    
    //MARK: Printing
    @IBAction func printText(_ sender: UIButton) {
        let textArray = [
            "Congratulations!",
            "Today is your day.",
            "You're off to Great Places!",
            "You're off and away!",
            "You have brains in your head.",
            "You have feet in your shoes.",
            "You can steer yourself",
            "any direction you choose.",
            "You're on your own. And you know what you know.",
            "And YOU are the one who'll decide where to go."
        ]
        
        guard let request = PrintRequest(text: textArray, printRequestId: self.uniquePrintId, printDeviceId: self.selectedPrinter?.id) else {
            debugPrint("Unsuccessfully created text PrintRequest. Was text provided to the request object?")
            return
        }

        self.issuePrintJob(request)
    }
    
    @IBAction func printImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func printURL(_ sender: UIButton) {
        guard let validURL = verifyUrl(urlTF.text) else { return }
        let request = PrintRequest(imageURL: validURL, printRequestId: self.uniquePrintId, printDeviceId: self.selectedPrinter?.id)
        
        self.issuePrintJob(request)
    }
    
    func retrievePrinters(completion: ((response:RetrievePrintersResponse) -> Void)?) {
        let request = RetrievePrintersRequest(printerCategory: nil)
        appDelegate?.cloverConnector?.retrievePrinters(request)
        
        //connector listener holds the callback that's passed here, so we can populate the tableView with the discovered printers
        appDelegate?.cloverConnectorListener?.getPrintersCallback = completion
    }
    
    private func verifyUrl(urlString: String?) -> NSURL? {
        guard let urlString = urlString,
            let url = NSURL(string: urlString) else {
                return nil
        }
        
        return (UIApplication.sharedApplication().canOpenURL(url) ? url : nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// Private wrapper around print call that issues the request, configures the app and UI for printing, and sets up a callback for status
    ///
    /// - Parameter request: PrintRequest object containing the information needed to begin a print job
    private func issuePrintJob(_ request: PrintRequest) {
        if let appDelegate = self.appDelegate {
            //kick off the print request
            appDelegate.cloverConnector?.print(request)
            
            //the rest of this scope works to monitor the print job. This can only be done if a printRequestID exists
            guard let printRequestId = request.printRequestId else { return }
            
            //setup the UI for async waiting on the print job
            spinner.startAnimating()
            UIApplication.sharedApplication().idleTimerDisabled = true
            
            self.queryPrintStatus(printRequestId)
        }
    }
    
    private func queryPrintStatus(_ printRequestId: String) {
        //this closure is kept on the listener, catches the first status update for this printRequestId (after it hits the Mini's printer spool), and then polls until the print job is done
        self.appDelegate?.cloverConnectorListener?.printJobStatusDict[printRequestId] = { [weak self] (response:PrintJobStatusResponse) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if response.status == .IN_QUEUE || response.status == .PRINTING { //since we're not done, perform another query after a short delay
                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                    dispatch_after(time, dispatch_get_main_queue(), {
                        let request = PrintJobStatusRequest(printRequestId)
                        self?.appDelegate?.cloverConnector?.retrievePrintJobStatus(request)
                    })
                } else {
                    self?.spinner.stopAnimating()
                    UIApplication.sharedApplication().idleTimerDisabled = false
                    self?.appDelegate?.cloverConnectorListener?.printJobStatusDict.removeValueForKey(printRequestId)
                }
                
                self?.appDelegate?.cloverConnectorListener?.showMessage("Print Job: " + printRequestId + "   Status: " + response.status.rawValue)
            })
        }
    }
}

extension PrintTestViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return printers?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let printer = printers?.optionalElement(indexPath.row) else {
            debugPrint("Tried to display printer that didn't exist. Off-by-one error?")
            return UITableViewCell()
        }
        
        let cell = self.printerTableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        if let _ = cell.textLabel,
            let _ = cell.detailTextLabel {
            cell.textLabel!.text = printer.name
            cell.detailTextLabel!.text = printer.id ?? "" + (printer.ipAddress != nil ? (" - " + printer.ipAddress!) : "")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedIndexPath == indexPath {
            self.printerTableView.deselectRowAtIndexPath(indexPath, animated: true)
            selectedIndexPath = nil
        } else {
            self.printerTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Top)
            selectedIndexPath = indexPath
        }
    }
}

extension PrintTestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        defer {
            dismissViewControllerAnimated(true, completion: nil)
        }
        
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            debugPrint("Error loading image")
            return
        }
        
        self.spinner.startAnimating()
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        self.resizeImage(pickedImage) { [weak self] (image) in
            let request = PrintRequest(image: image, printRequestId: self?.uniquePrintId, printDeviceId: self?.selectedPrinter?.id)
            self?.issuePrintJob(request)
        }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// Resizes an image to fit within CloverConnector.MAX_PAYLOAD_SIZE
    func resizeImage(_ image:UIImage, completion: ((image: UIImage) -> Void)?) {
        var scaledImage = image
        guard var scaledData = UIImagePNGRepresentation(image) else {
            completion?(image: image)
            return
        }
        
        guard let cloverConnector = self.appDelegate?.cloverConnector else {
            completion?(image: image)
            return
        }
        
        debugPrint("Start Size: " + String(scaledImage.size))
        
        //throw onto a background queue because of how heavy the resize could be
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            while scaledData.length > cloverConnector.MAX_PAYLOAD_SIZE {
                var scale = sqrt((CGFloat(cloverConnector.MAX_PAYLOAD_SIZE) / CGFloat(scaledData.length)))
                scale = scale > 0.9 ? 0.9 : scale
                debugPrint("Scaling " + String(scale) + "%")
                let newSize = CGSize(width: scaledImage.size.width * scale, height: scaledImage.size.height * scale)
                UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
                scaledImage.drawInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
                guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
                    dispatch_async(dispatch_get_main_queue(), {
                        completion?(image: scaledImage)
                    })
                    return
                }
                scaledImage = newImage
                guard let newData = UIImagePNGRepresentation(scaledImage) else {
                    dispatch_async(dispatch_get_main_queue(), {
                        completion?(image: scaledImage)
                    })
                    return
                }
                
                scaledData = newData
                UIGraphicsEndImageContext()
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                debugPrint("Final Size: " + String(scaledImage.size))
                completion?(image:scaledImage)
            })
        })
    }
}

private extension Array {
    func optionalElement(_ i: Index) -> Element? {
        return indices.contains(i) ? self[i] : nil
    }
}
