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

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var endpointTextField: UITextField!
    @IBOutlet var cameraPreview: UIView!
    @IBOutlet var closeButton: UIButton!
    
    private let WS_ENDPOINT = "WS_ENDPOINT"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedEndpoint = NSUserDefaults.standardUserDefaults().stringForKey(WS_ENDPOINT) {
            endpointTextField.text = savedEndpoint
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func longPressConnect(sender: UIButton) {
        connect(true)
    }
    @IBAction func tapConnect(sender: AnyObject) {
        connect(false)
    }
    
    private func connect(forcePairing:Bool) {
        if let endpoint = endpointTextField.text {
            debugPrint(endpoint)
            NSUserDefaults.standardUserDefaults().setValue(endpoint, forKey: WS_ENDPOINT)
            if forcePairing {
                (UIApplication.sharedApplication().delegate as! AppDelegate).clearConnect(endpoint)
            } else {
                (UIApplication.sharedApplication().delegate as! AppDelegate).connect(endpoint)
            }
        }
    }
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    
    @IBAction func closeButton(sender: AnyObject?) {
        self.closeButton.hidden = true
        self.captureSession?.stopRunning()
        self.cameraPreview.hidden = true
    }
    
    @IBAction func qrTapped(sender: AnyObject) {
        self.cameraPreview?.hidden = false
        self.closeButton.hidden = false
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        do {
            guard let input: AnyObject! = try AVCaptureDeviceInput(device:captureDevice) else {
                debugPrint("Error getting ACCaptureDeviceInput")
                return
            }
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            if let ip = input as? AVCaptureInput {
                captureSession?.addInput(ip)
            } else {
                return
            }
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_queue_create("com.clover.examplepos.qr_queue", DISPATCH_QUEUE_SERIAL))
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            if let vpl = videoPreviewLayer {
                
                vpl.videoGravity = AVLayerVideoGravityResizeAspectFill
                vpl.frame = cameraPreview.layer.bounds
                cameraPreview.layer.addSublayer(vpl)
                captureSession?.startRunning()
            } else {
                videoPreviewLayer = nil // should be nil or we wouldn't get here
                captureSession = nil
            }
            
        } catch {
            debugPrint("error getting capture device input")
        }
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            if metadataObjects == nil || metadataObjects.count == 0 {
                debugPrint("no QR code detected")
                return
            }
            
            if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                if metadataObj.type == AVMetadataObjectTypeQRCode {
                    if metadataObj.stringValue != nil {
                        self?.captureSession?.stopRunning()
                        self?.cameraPreview.hidden = true
                        if let appDel = (UIApplication.sharedApplication().delegate as? AppDelegate) {
                            appDel.connect(metadataObj.stringValue)
                            self?.closeButton.hidden = true
                        }
                    }
                } else {
                    debugPrint("Expected AVMetadataObjectypeQRCode, but is " + metadataObj.type)
                }
            } else {
                debugPrint("Unexpected metadata object. expected AVMetadataMachineReadableCodeObject")
            }
            })
        
    }
    
}

