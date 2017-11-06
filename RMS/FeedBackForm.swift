//
//  FeedBackForm.swift
//  RMS
//
//  Created by Mac Mini on 7/9/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit

class FeedBackForm: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    let constants = Constants();
    let webserviceManager = WebserviceManager();
    
    @IBOutlet weak var background: UIScrollView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var descriptin: UITextView!
    @IBOutlet weak var question: UISwitch!
    @IBOutlet weak var suggestion: UISwitch!
    @IBOutlet weak var problem: UISwitch!
    @IBOutlet weak var connect: UISwitch!
    var activeField: UITextField?
    var activeText: UITextView?
    
    override func viewDidLoad() {
        background.backgroundColor = UIColor(patternImage: UIImage(named: "background-1")!)
        
        descriptin.delegate = self
        name.delegate = self
        subject.delegate = self
        mobileNumber.delegate = self
        descriptin.backgroundColor = UIColor.clear
        descriptin.layer.contents = UIImage(named: "comments-big")!.cgImage
        descriptin.text = "Description"
        descriptin.textColor = UIColor.lightGray
        
        question.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        suggestion.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        problem.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        connect.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        question.addTarget(self, action: #selector(self.switchIsChanged(mySwitch:)), for: UIControlEvents.valueChanged)
        suggestion.addTarget(self, action: #selector(self.switchIsChanged(mySwitch:)), for: UIControlEvents.valueChanged)
        problem.addTarget(self, action: #selector(self.switchIsChanged(mySwitch:)), for: UIControlEvents.valueChanged)
        connect.addTarget(self, action: #selector(self.switchIsChanged(mySwitch:)), for: UIControlEvents.valueChanged)
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: 3, height: self.name.frame.size.height)
        name.leftView = paddingView
        name.leftViewMode = UITextFieldViewMode.always
        
        let paddingView1 = UIView()
        paddingView1.frame = CGRect(x: 0, y: 0, width: 3, height: self.name.frame.size.height)
        mobileNumber.leftView = paddingView1
        mobileNumber.leftViewMode = UITextFieldViewMode.always
        
        let paddingView2 = UIView()
        paddingView2.frame = CGRect(x: 0, y: 0, width: 3, height: self.name.frame.size.height)
        subject.leftView = paddingView2
        subject.leftViewMode = UITextFieldViewMode.always
        
        hideKeyboard()
        addDoneButtonOnKeyboard()
        registerForKeyboardNotifications()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (descriptin.textColor == UIColor.lightGray && descriptin.text == "Description") {
            descriptin.text = ""
            descriptin.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptin.text.isEmpty {
            descriptin.text = "Description"
            descriptin.textColor = UIColor.lightGray
        }
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        if (scoreText == self.name) {
            name.resignFirstResponder()
            mobileNumber.becomeFirstResponder()
        } else if (scoreText == self.subject) {
            subject.resignFirstResponder()
            descriptin.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        return true
    }
    
    func textViewShouldReturn(_ scoreText: UITextView) -> Bool {
        deregisterFromKeyboardNotifications()
        self.view.endEditing(true)
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == mobileNumber) {//This makes the new text black.
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= constants.limitLength
        }
        return true
    }
    
    @IBAction func submit(_ sender: Any) {
        var contectTypes = ""
        let name1 = name.text ?? ""
        let subject1 = subject.text ?? ""
        let desc = descriptin.text ?? ""
        let mobile = mobileNumber.text ?? ""
        if ((name1.length) <= 0 || (subject1.length) <= 0 || (mobile.length) <= 0 || (desc.length) <= 0) {
            self.alertDialog (heading: "", message: self.constants.allFieldsErrorMessage, result: "Error");
        } else if (!constants.isValidMobileNumber(mobile: mobile)) {
            self.alertDialog (heading: "", message: self.constants.validMobileNumberError, result: "Error");
        } else {
            if (!question.isOn && !suggestion.isOn && !problem.isOn && !connect.isOn) {
                self.alertDialog (heading: "", message: self.constants.allFieldsErrorMessage, result: "Error");
            } else {
                self.view.endEditing(true)
                deregisterFromKeyboardNotifications()
                DispatchQueue.main.async(execute: {
                    /* Do some heavy work (you are now on a background queue) */
                    LoadingIndicatorView.show(self.constants.feedbackLoading)
                });
                if (question.isOn){
                    contectTypes = contectTypes + "Question"
                }
                if (suggestion.isOn){
                    if (contectTypes == "") {
                        contectTypes = contectTypes + "Suggestion"
                    } else {
                        contectTypes = contectTypes + ",Suggestion"
                    }
                }
                if (problem.isOn){
                    if (contectTypes == "") {
                        contectTypes = contectTypes + "Problem"
                    } else {
                        contectTypes = contectTypes + ",Problem"
                    }
                }
                if connect.isOn{
                    if (contectTypes == "") {
                        contectTypes = contectTypes + "Contact"
                    } else {
                        contectTypes = contectTypes + ",Contact"
                    }
                }
                self.sendFeedback(actionId: "post_feedback", name: name1, phoneNumber: mobile, contactType: contectTypes, subject: subject1, description: desc)
            }
        }
    }
    
    func switchIsChanged(mySwitch: UISwitch) {
        deregisterFromKeyboardNotifications()
        self.view.endEditing(true)
    }
    
    func sendFeedback(actionId: String, name: String, phoneNumber: String, contactType: String, subject: String, description: String) -> Void {
        let MemberName = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let Subject = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let Comments = description.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let PhoneNumber = phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let endPoint: String = {
            return "\(constants.BASE_URL)?action_id=\(actionId)&mobile_no=\(PhoneNumber)&name=\(MemberName)&subject=\(Subject)&contact_types=\(contactType)&description=\(Comments)"
        }()
        
        self.webserviceManager.login(type: "single", endPoint: endPoint) { (result) in
            LoadingIndicatorView.hideInMain()
            switch result {
            case .SuccessSingle( _, let message):
                self.alertDialog (heading: "", message: message, result: "Success");
            case .Error(let message):
                self.alertDialog (heading: "", message: message, result: "Success");
            default:
                self.alertDialog (heading: "", message: self.constants.errorMessage, result: "Error");
                
            }
        }
        self.registerForKeyboardNotifications()
    }
    
    func alertDialog (heading: String, message: String, result: String) {
        OperationQueue.main.addOperation {
            if (result == "Success") {
                self.name.text  = ""
                self.subject.text  = ""
                self.mobileNumber.text  = ""
                self.descriptin.text  = ""
                self.name.placeholder  = " Your Name"
                self.subject.placeholder  = " Subject"
                self.mobileNumber.placeholder  = " Mobile Number"
                self.descriptin.text = "Description"
                self.descriptin.textColor = UIColor.lightGray
                if (self.question.isOn) {
                    self.question.isOn = false
                }
                if (self.suggestion.isOn) {
                    self.suggestion.isOn = false
                }
                if (self.problem.isOn) {
                    self.problem.isOn = false
                }
                if (self.connect.isOn) {
                    self.connect.isOn = false
                }
            }
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.background.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height*1.8, 0.0)
        
        self.background.contentInset = contentInsets
        self.background.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.background.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
        if let activeText = self.activeText {
            if (!aRect.contains(activeText.frame.origin)){
                self.background.scrollRectToVisible(activeText.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.background.contentInset = contentInsets
        self.background.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.background.contentInset.bottom = keyboardSize!.height
        //        self.scrollView.isScrollEnabled = false
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(Enquiry.doneButtonAction))
        done.tintColor = .black
        
        let items = NSMutableArray()
        items.add(flexSpace)
        items.add(done)
        
        doneToolbar.items = items as? [UIBarButtonItem]
        doneToolbar.sizeToFit()
        
        self.mobileNumber.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        if (mobileNumber.isFirstResponder) {
            mobileNumber.resignFirstResponder()
            subject.becomeFirstResponder()
        }
    }
}
