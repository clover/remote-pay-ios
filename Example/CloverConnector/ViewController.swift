//
//  ViewController.swift
//  ExamplePOS
//
//  
//  Copyright © 2017 Clover Network, Inc. All rights reserved.
//

import UIKit
import CloverConnector
import Intents
import AVKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet var connectButton: UIButton!
    @IBOutlet var endpointTextField: UITextField!
    @IBOutlet var cameraPreview: UIView!
    @IBOutlet var closeButton: UIButton!
    var blurredView: UIVisualEffectView?
    
    fileprivate let WS_ENDPOINT = "WS_ENDPOINT"
    
    var appDelegate: AppDelegate? {
        return (UIApplication.shared.delegate as? AppDelegate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedEndpoint = UserDefaults.standard.string(forKey: WS_ENDPOINT) {
            endpointTextField.text = savedEndpoint
        }
    }

    @IBAction func longPressConnect(_ sender: UIButton) {
        connect(true)
    }
    @IBAction func tapConnect(_ sender: AnyObject) {
        connect(false)
    }
    
    fileprivate func connect(_ forcePairing:Bool) {
        if let endpoint = endpointTextField.text {
            debugPrint(endpoint)
            UserDefaults.standard.setValue(endpoint, forKey: WS_ENDPOINT)
            if forcePairing {
                appDelegate?.clearConnect(endpoint)
            } else {
                appDelegate?.connect(endpoint)
            }
        }
    }
    
    //MARK: QR Pairing
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    
    @IBAction func qrTapped(sender: AnyObject) {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            debugPrint("Error getting AVCaptureDevice")
            return
        }
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        do {
            let input = try AVCaptureDeviceInput(device:captureDevice)
            
            // Initialize the captureSession object, and set the input device on the capture session.
            let validCaptureSession = AVCaptureSession()
            captureSession = validCaptureSession
            validCaptureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            validCaptureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue(label: "com.clover.examplepos.qr_queue"))
            captureMetadataOutput.metadataObjectTypes = [.qr]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: validCaptureSession)
            if let vpl = videoPreviewLayer {
                vpl.videoGravity = .resizeAspectFill
                vpl.frame = cameraPreview.layer.bounds
                cameraPreview.layer.addSublayer(vpl)
                validCaptureSession.startRunning()
                
                self.cameraPreview.alpha = 0.0
                self.closeButton.alpha = 0.0
                self.cameraPreview?.isHidden = false
                self.closeButton?.isHidden = false
                
                UIView.animate(withDuration: 0.3, animations: { //animate in the blur...
                    self.blurredView = UIVisualEffectView(frame: self.view.frame)
                    self.blurredView?.effect = UIBlurEffect(style: .light)
                    
                    if let validBlurView = self.blurredView {
                        self.view.insertSubview(validBlurView, belowSubview: self.cameraPreview)
                    }
                }, completion: { (success) in
                    UIView.animate(withDuration: 0.3, animations: { //...then animate in the camera preview
                        self.cameraPreview.alpha = 1.0
                        self.closeButton.alpha = 1.0
                    })
                })
            } else {
                videoPreviewLayer = nil // should be nil or we wouldn't get here
                captureSession = nil
            }
        } catch {
            debugPrint("error getting capture device input")
        }
    }
    
    @IBAction func closeButton(_ sender: UIButton?) {
        self.captureSession?.stopRunning()
    
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.cameraPreview.alpha = 0.0
            self?.closeButton.alpha = 0.0
            self?.blurredView?.effect = nil
        }) { [weak self] (success) in
            self?.videoPreviewLayer?.isHidden = true
            self?.cameraPreview.isHidden = true
            self?.closeButton.isHidden = true
            self?.blurredView?.removeFromSuperview()
        }
    }
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        DispatchQueue.main.async { [weak self] in
            guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
                debugPrint("No metadata found in capture session")
                return
            }
            
            guard metadataObj.type == .qr else {
                debugPrint("Expected AVMetadataObjectypeQRCode, but is " + metadataObj.type.rawValue)
                return
            }
            
            //get string from the QR code, and make sure it's a valid URL
            if let urlValue = metadataObj.stringValue, let _ = URL(string: urlValue) {
                self?.closeButton(nil)
                self?.appDelegate?.connect(urlValue)
                
                //clean up the string to put in the text field (remove the auth token and "?")
                var cleanedString: String? = urlValue
                var components = URLComponents(string: urlValue)
                if let index = components?.queryItems?.index(where: { $0.name == "authenticationToken"}) {
                    components?.queryItems?.remove(at: index)
                    cleanedString = components?.url?.absoluteString
                }
                
                if components?.url?.absoluteString.characters.last == "?" {
                    if var string = components?.url?.absoluteString {
                        string.removeLast()
                        cleanedString = string
                    }
                }
                
                self?.endpointTextField.text = cleanedString
            }
        }
    }
}

