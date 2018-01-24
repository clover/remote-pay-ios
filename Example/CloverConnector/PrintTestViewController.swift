//
//  PrintTestViewController.swift
//  CloverConnector
//
//  Created by Clover on 9/13/17.
//  Copyright © 2017 Clover Networks, Inc. All rights reserved.
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
    
    var selectedIndexPath: IndexPath?
    var selectedPrinter: CLVModels.Printer.Printer? {
        if let index = self.printerTableView.indexPathForSelectedRow?.row {
            return self.printers?.optionalElement(index)
        }
        
        return nil
    }
    
    var appDelegate: AppDelegate? {
        get {
            return UIApplication.shared.delegate as? AppDelegate
        }
    }
    
    var uniquePrintId: String {
        get {
            return "\(arc4random())"
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
            self.closeButton.isHidden = true
        } else {
            self.closeButton.isHidden = false
        }
        
        //delegation handled in extension
        printerTableView.delegate = self
        printerTableView.dataSource = self
        
        //fetch the accessible printers
        spinner.startAnimating()
        retrievePrinters { [weak self] (response) in
            DispatchQueue.main.async {
                self?.spinner.stopAnimating()
                self?.printers = response.printers
                self?.printerTableView.reloadData()
            }
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
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func printURL(_ sender: UIButton) {
        guard let validURL = verifyUrl(urlString: urlTF.text) else { return }
        
        let request = PrintRequest(imageURL: validURL, printRequestId: self.uniquePrintId, printDeviceId: self.selectedPrinter?.id)
        self.issuePrintJob(request)
    }
    
    func retrievePrinters(completion: ((_ response:RetrievePrintersResponse) -> Void)?) {
        let request = RetrievePrintersRequest(printerCategory: nil)
        appDelegate?.cloverConnector?.retrievePrinters(request)
        
        //connector listener holds the callback that's passed here, so we can populate the tableView with the discovered printers
        appDelegate?.cloverConnectorListener?.getPrintersCallback = completion
    }
    
    private func verifyUrl(urlString: String?) -> URL? {
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
                return nil
        }
        
        return (UIApplication.shared.canOpenURL(url) ? url : nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
            UIApplication.shared.isIdleTimerDisabled = true
            
            self.queryPrintStatus(printRequestId)
        }
    }
    
    private func queryPrintStatus(_ printRequestId: String) {
        //this closure is kept on the listener, catches the first status update for this printRequestId (after it hits the Mini's printer spool), and then polls until the print job is done
        self.appDelegate?.cloverConnectorListener?.printJobStatusDict[printRequestId] = { [weak self] (response:PrintJobStatusResponse) -> Void in
            DispatchQueue.main.async {
                if response.status == .IN_QUEUE || response.status == .PRINTING { //since we're not done, perform another query after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        let request = PrintJobStatusRequest(printRequestId)
                        self?.appDelegate?.cloverConnector?.retrievePrintJobStatus(request)
                    })
                } else {
                    self?.spinner.stopAnimating()
                    UIApplication.shared.isIdleTimerDisabled = false
                    self?.appDelegate?.cloverConnectorListener?.printJobStatusDict.removeValue(forKey: printRequestId)
                }
                
                self?.appDelegate?.cloverConnectorListener?.showMessage("Print Job: " + printRequestId + "   Status: " + response.status.rawValue)
            }
        }
    }
}

extension PrintTestViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return printers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let printer = printers?.optionalElement(indexPath.row) else {
            debugPrint("Tried to display printer that didn't exist. Off-by-one error?")
            return UITableViewCell()
        }
        
        let cell = self.printerTableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if let _ = cell.textLabel,
            let _ = cell.detailTextLabel {
            cell.textLabel!.text = printer.name
            cell.detailTextLabel!.text = printer.id ?? "" + (printer.ipAddress != nil ? (" - " + printer.ipAddress!) : "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            self.printerTableView.deselectRow(at: indexPath, animated: true)
            selectedIndexPath = nil
        } else {
            self.printerTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            selectedIndexPath = indexPath
        }
    }
}

extension PrintTestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            debugPrint("Error loading image")
            return
        }
        
        self.spinner.startAnimating()
        UIApplication.shared.isIdleTimerDisabled = true
        

        self.resizeImage(image: pickedImage) { [weak self] (resizedImage) in
            let request = PrintRequest(image: resizedImage, printRequestId: self?.uniquePrintId, printDeviceId: self?.selectedPrinter?.id)
            self?.issuePrintJob(request)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Resizes an image to fit within CloverConnector.MAX_PAYLOAD_SIZE
    func resizeImage(image:UIImage, completion: ((_ image: UIImage) -> Void)?) {
        var scaledImage = image
        guard var scaledData = UIImagePNGRepresentation(image) else {
            completion?(image)
            return
        }
        
        guard let cloverConnector = appDelegate?.cloverConnector else {
            completion?(image)
            return
        }
        
        debugPrint("Start Size: " + String(describing: scaledImage.size))
        
        //throw onto a background queue because of how heavy the resize could be
        DispatchQueue.global().async {
            while scaledData.count > cloverConnector.MAX_PAYLOAD_SIZE {
                var scale = sqrt((CGFloat(cloverConnector.MAX_PAYLOAD_SIZE) / CGFloat(scaledData.count)))
                scale = scale > 0.9 ? 0.9 : scale
                debugPrint("Scaling " + String(describing: scale) + "%")
                let newSize = CGSize(width: scaledImage.size.width * scale, height: scaledImage.size.height * scale)
                UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
                scaledImage.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
                guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
                    DispatchQueue.main.async { completion?(scaledImage) }
                    return
                }
                scaledImage = newImage
                guard let newData = UIImagePNGRepresentation(scaledImage) else {
                    DispatchQueue.main.async { completion?(scaledImage) }
                    return
                }
                
                scaledData = newData
                UIGraphicsEndImageContext()
            }
            
            DispatchQueue.main.async {
                debugPrint("Final Size: " + String(describing: scaledImage.size))
                completion?(scaledImage)
            }
        }
    }
}

fileprivate extension Array {
    func optionalElement(_ i: Index) -> Element? {
        return indices.contains(i) ? self[i] : nil
    }
}

