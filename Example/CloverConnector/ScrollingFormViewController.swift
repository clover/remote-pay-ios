//
//  ScrollingFormViewController.swift
//  CloverConnector
//
//  
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import NotificationCenter

class ScrollingFormViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    var activeFieldRect: CGRect?
    var keyboardRect: CGRect?
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.registerForKeyboardNotifications()
        for view in self.view.subviews {
            if view is UITextView {
                let tv = view as! UITextView
                tv.delegate = self
            } else if view is UITextField {
                let tf = view as! UITextField
                tf.delegate = self
            }
        }
        scrollView = UIScrollView(frame: self.view.frame)
        scrollView.scrollEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.addSubview(self.view)
        self.view = scrollView
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.sizeToFit()
        scrollView.contentSize = scrollView.frame.size
        super.viewDidLayoutSubviews()
    }
    
    deinit {
        self.deregisterFromKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScrollingFormViewController.keyboardWasShown), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScrollingFormViewController.keyboardWillBeHidden), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        let info : NSDictionary = notification.userInfo! as NSDictionary
        keyboardRect = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        adjustForKeyboard()
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        keyboardRect = nil
        adjustForKeyboard()
    }
    
    func adjustForKeyboard() {
        if keyboardRect != nil && activeFieldRect != nil {
            let aRect : CGRect = scrollView.convertRect(activeFieldRect!, toView: nil)
            if (keyboardRect!.contains(CGPoint(x: aRect.origin.x, y: aRect.maxY)))
            {
                scrollView.scrollEnabled = true
                let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardRect!.size.height, 0.0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
                scrollView.scrollRectToVisible(activeFieldRect!, animated: true)
            }
        } else {
            let contentInsets : UIEdgeInsets = UIEdgeInsets()
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            scrollView.scrollEnabled = false
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        activeFieldRect = textView.frame
        adjustForKeyboard()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        activeFieldRect = nil
        adjustForKeyboard()
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        activeFieldRect = textField.frame
        adjustForKeyboard()
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        activeFieldRect = nil
        adjustForKeyboard()
    }
    
}
