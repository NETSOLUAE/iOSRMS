//
//  RegistrationController.swift
//  RMS
//
//  Created by Mac Mini on 9/12/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit

class RegistrationController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    var dateSelected = ""
    let constants = Constants();
    let webserviceManager = WebserviceManager();
    
    @IBOutlet weak var background: UIScrollView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var dob: UIButton!
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var nationalId: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateTool: UIView!
    @IBOutlet weak var userName: UITextField!
    var activeField: UITextField?
    
    @IBAction func selectDate(_ sender: Any) {
        self.view.endEditing(true)
        deregisterFromKeyboardNotifications()
        var date = ""
        var color = ""
        if (self.dateSelected == "") {
            date = "Date of Birth"
            color = "#C7C7CD"
        } else {
            date = self.dateSelected
            color = "#000000"
        }
        self.dob.setTitle(date, for: .normal)
        self.dob.setTitleColor(UIColor().HexToColor(hexString: color, alpha: 1.0), for: .normal)
        self.datePicker.isHidden = !self.datePicker.isHidden
        self.dateTool.isHidden = !self.dateTool.isHidden
    }
    @IBAction func done(_ sender: Any) {
        registerForKeyboardNotifications()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let strDate = dateFormatter.string(from: datePicker.date)
        self.dateSelected = strDate
        self.dob.setTitle(self.dateSelected, for: .normal)
        self.dob.setTitleColor(UIColor().HexToColor(hexString: "#000000", alpha: 1.0), for: .normal)
        self.datePicker.isHidden = !self.datePicker.isHidden
        self.dateTool.isHidden = !self.dateTool.isHidden
    }
    @IBAction func cancel(_ sender: Any) {
        registerForKeyboardNotifications()
        self.datePicker.isHidden = !self.datePicker.isHidden
        self.dateTool.isHidden = !self.dateTool.isHidden
    }
    
    override func viewDidLoad() {
        background.backgroundColor = UIColor(patternImage: UIImage(named: "background-1")!)
        
        name.delegate = self
        mobileNumber.delegate = self
        companyName.delegate = self
        email.delegate = self
        nationalId.delegate = self
        userName.delegate = self
        password.delegate = self
        confirmPassword.delegate = self
        self.datePicker.isHidden = true
        self.dateTool.isHidden = true
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: 5, height: self.name.frame.size.height)
        name.leftView = paddingView
        name.leftViewMode = UITextFieldViewMode.always
        
        let paddingView1 = UIView()
        paddingView1.frame = CGRect(x: 0, y: 0, width: 5, height: self.name.frame.size.height)
        mobileNumber.leftView = paddingView1
        mobileNumber.leftViewMode = UITextFieldViewMode.always
        
        let paddingView2 = UIView()
        paddingView2.frame = CGRect(x: 0, y: 0, width: 5, height: self.name.frame.size.height)
        companyName.leftView = paddingView2
        companyName.leftViewMode = UITextFieldViewMode.always
        
        let paddingView3 = UIView()
        paddingView3.frame = CGRect(x: 0, y: 0, width: 5, height: self.name.frame.size.height)
        email.leftView = paddingView3
        email.leftViewMode = UITextFieldViewMode.always
        
        let paddingView4 = UIView()
        paddingView4.frame = CGRect(x: 0, y: 0, width: 5, height: self.name.frame.size.height)
        nationalId.leftView = paddingView4
        nationalId.leftViewMode = UITextFieldViewMode.always
        
        let paddingView7 = UIView()
        paddingView7.frame = CGRect(x: 0, y: 0, width: 5, height: self.name.frame.size.height)
        userName.leftView = paddingView7
        userName.leftViewMode = UITextFieldViewMode.always
        
        let paddingView5 = UIView()
        paddingView5.frame = CGRect(x: 0, y: 0, width: 5, height: self.name.frame.size.height)
        password.leftView = paddingView5
        password.leftViewMode = UITextFieldViewMode.always
        
        let paddingView6 = UIView()
        paddingView6.frame = CGRect(x: 0, y: 0, width: 5, height: self.name.frame.size.height)
        confirmPassword.leftView = paddingView6
        confirmPassword.leftViewMode = UITextFieldViewMode.always
        self.datePicker.maximumDate = Date()
        
        self.datePicker.backgroundColor = UIColor().HexToColor(hexString: "#EBEBEB", alpha: 1.0)
        self.dateTool.backgroundColor = UIColor().HexToColor(hexString: "#EBEBEB", alpha: 1.0)
        registerForKeyboardNotifications()
        addDoneButtonOnKeyboard()
        hideKeyboard()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        if (scoreText == self.name) {
            name.resignFirstResponder()
            mobileNumber.becomeFirstResponder()
        } else if (scoreText == self.companyName) {
            companyName.resignFirstResponder()
            email.becomeFirstResponder()
        } else if (scoreText == self.email) {
            email.resignFirstResponder()
            nationalId.becomeFirstResponder()
        } else if (scoreText == self.userName) {
            userName.resignFirstResponder()
            password.becomeFirstResponder()
        } else if (scoreText == self.password) {
            password.resignFirstResponder()
            confirmPassword.becomeFirstResponder()
        } else if (scoreText == self.confirmPassword) {
            self.view.endEditing(true)
        } else {
            self.view.endEditing(true)
        }
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
        self.view.endEditing(true)
        let name1 = name.text ?? ""
        let mobile = mobileNumber.text ?? ""
        let companyName = self.companyName.text ?? ""
        let email1 = email.text ?? ""
        let nationalId1 = nationalId.text ?? ""
        let userName1 = userName.text ?? ""
        let password1 = password.text ?? ""
        let confirmPassword1 = confirmPassword.text ?? ""
        if ((name1.length) <= 0 || (mobile.length) <= 0 || (self.dateSelected.length) <= 0 || (companyName.length) <= 0 || (companyName.length) <= 0
            || (email1.length) <= 0 || (nationalId1.length) <= 0 || (userName1.length) <= 0 || (password1.length) <= 0 || (confirmPassword1.length) <= 0) {
            self.alertDialog (heading: "", message: self.constants.allFieldsErrorMessage, internalMessage: true, result: "Error");
        } else if (password1 != confirmPassword1){
            self.alertDialog (heading: "", message: self.constants.passwordMismatchError, internalMessage: true, result: "Error");
        } else if (!isValidEmail(email: email1)){
            self.alertDialog (heading: "", message: self.constants.validEmailErrorMessage, internalMessage: true, result: "Error");
        } else if (!constants.isValidMobileNumber(mobile: mobile)) {
            self.alertDialog (heading: "", message: self.constants.validMobileNumberError, internalMessage: true, result: "Error");
        } else if (confirmPassword1.length < 6) {
            self.alertDialog (heading: "", message: self.constants.passwordLengthError, internalMessage: true, result: "Error");
        } else {
            self.view.endEditing(true)
            deregisterFromKeyboardNotifications()
            DispatchQueue.main.async(execute: {
                /* Do some heavy work (you are now on a background queue) */
                LoadingIndicatorView.show(self.constants.registrationLoading)
            });
            self.sendRegistration(actionId: "new_registration", name: name1, dob: self.dateSelected, phoneNumber: mobile, companyName: companyName, email1: email1, nationalId1: nationalId1, userName: userName1, password1: password1)
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
    
    func sendRegistration(actionId: String, name: String, dob: String, phoneNumber: String, companyName: String, email1: String, nationalId1: String, userName: String, password1: String) -> Void {
        
        let endPoint1: String = {
            return "\(constants.BASE_URL)?action_id=\(actionId)&mobile_no=\(phoneNumber)&full_name=\(name)&date_of_birth=\(dob)&company_name=\(companyName)&national_id=\(nationalId1)&email=\(email1)&password=\(password1)&username=\(userName)"
        }()
        let endPoint = NSString(format: endPoint1 as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        self.webserviceManager.login(type: "single", endPoint: endPoint) { (result) in
            LoadingIndicatorView.hideInMain()
            switch result {
            case .SuccessSingle( _, let message):
                self.alertDialog (heading: "", message: message, internalMessage: false, result: "Success");
            case .Error(let message):
                self.alertDialog (heading: "", message: message, internalMessage: false, result: "Success");
            default:
                self.alertDialog (heading: "", message: self.constants.errorMessage, internalMessage: false, result: "Error");
                
            }
        }
        registerForKeyboardNotifications()
    }

    func alertDialog (heading: String, message: String, internalMessage: Bool, result: String) {
        OperationQueue.main.addOperation {
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            if (!internalMessage) {
                if (result == "Success") {
                    self.name.text  = ""
                    self.mobileNumber.text  = ""
                    self.companyName.text  = ""
                    self.email.text  = ""
                    self.nationalId.text  = ""
                    self.userName.text  = ""
                    self.password.text  = ""
                    self.confirmPassword.text  = ""
                    self.name.placeholder  = "Your Name"
                    self.mobileNumber.placeholder  = "Mobile Number"
                    self.companyName.placeholder = "Company Name"
                    self.email.placeholder = "Email"
                    self.nationalId.placeholder  = "National ID"
                    self.userName.placeholder  = "User Name"
                    self.password.placeholder  = "Password"
                    self.confirmPassword.placeholder  = "Confirm Password"
                    self.dob.setTitle("Date of Birth", for: .normal)
                    self.dob.setTitleColor(UIColor().HexToColor(hexString: "#C7C7CD", alpha: 1.0), for: .normal)
                }
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    currentSelection.name = "ebclaims"
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "LoginController") as UIViewController
                    self.present(vc, animated: true, completion: nil)
                })
                alertController.addAction(defaultAction)
            } else {
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(RegistrationController.doneButtonAction))
        done.tintColor = .black
        
        let items = NSMutableArray()
        items.add(flexSpace)
        items.add(done)
        
        doneToolbar.items = items as? [UIBarButtonItem]
        doneToolbar.sizeToFit()
        
        self.mobileNumber.inputAccessoryView = doneToolbar
        self.nationalId.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        if (mobileNumber.isFirstResponder) {
            mobileNumber.resignFirstResponder()
            companyName.becomeFirstResponder()
        }
        if (nationalId.isFirstResponder) {
            nationalId.resignFirstResponder()
            userName.becomeFirstResponder()
        }
    }
    
    func isValidEmail(email: String) -> Bool {
        print("validate emilId: \(email)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        return result
    }
}
