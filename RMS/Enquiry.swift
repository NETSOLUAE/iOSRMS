//
//  Enquiry.swift
//  RMS
//
//  Created by Mac Mini on 8/26/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit

class Enquiry: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    var dateSelected = ""
    var startDateSelected = ""
    var endDateSelected = ""
    var selectedDate = ""
    let constants = Constants();
    let webserviceManager = WebserviceManager();
    
    @IBOutlet weak var background: UIScrollView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var nationalID: UITextField!
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var descriptin: UITextView!
    @IBOutlet weak var auto: UISwitch!
    @IBOutlet weak var house: UISwitch!
    @IBOutlet weak var life: UISwitch!
    @IBOutlet weak var health: UISwitch!
    @IBOutlet weak var dob: UIButton!
    @IBOutlet weak var insuranceStartDate: UIButton!
    @IBOutlet weak var insuranceEndDate: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var toolBar: UIView!
    var activeField: UITextField?
    var activeText: UITextView?
    
    override func viewDidLoad() {
        background.backgroundColor = UIColor(patternImage: UIImage(named: "background-1")!)
        
        descriptin.delegate = self
        name.delegate = self
        nationalID.delegate = self
        mobileNumber.delegate = self
        email.delegate = self
        descriptin.backgroundColor = UIColor.clear
        descriptin.layer.contents = UIImage(named: "comments-big")!.cgImage
        descriptin.text = "Description"
        descriptin.textColor = UIColor.lightGray
        self.datePicker.isHidden = true
        self.toolBar.isHidden = true
        
        auto.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        house.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        life.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        health.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        auto.addTarget(self, action: #selector(self.auto(mySwitch:)), for: UIControlEvents.valueChanged)
        house.addTarget(self, action: #selector(self.auto(mySwitch:)), for: UIControlEvents.valueChanged)
        life.addTarget(self, action: #selector(self.auto(mySwitch:)), for: UIControlEvents.valueChanged)
        health.addTarget(self, action: #selector(self.auto(mySwitch:)), for: UIControlEvents.valueChanged)
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: 3, height: self.name.frame.size.height)
        name.leftView = paddingView
        name.leftViewMode = UITextFieldViewMode.always
        
        let paddingView1 = UIView()
        paddingView1.frame = CGRect(x: 0, y: 0, width: 3, height: self.nationalID.frame.size.height)
        nationalID.leftView = paddingView1
        nationalID.leftViewMode = UITextFieldViewMode.always
        
        let paddingView2 = UIView()
        paddingView2.frame = CGRect(x: 0, y: 0, width: 3, height: self.mobileNumber.frame.size.height)
        mobileNumber.leftView = paddingView2
        mobileNumber.leftViewMode = UITextFieldViewMode.always
        
        let paddingView3 = UIView()
        paddingView3.frame = CGRect(x: 0, y: 0, width: 3, height: self.email.frame.size.height)
        email.leftView = paddingView3
        email.leftViewMode = UITextFieldViewMode.always
        
        self.datePicker.maximumDate = Date()
        self.datePicker.backgroundColor = UIColor().HexToColor(hexString: "#EBEBEB", alpha: 1.0)
        self.toolBar.backgroundColor = UIColor().HexToColor(hexString: "#EBEBEB", alpha: 1.0)
        
        addDoneButtonOnKeyboard()
        registerForKeyboardNotifications()
        hideKeyboard()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
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
        
        OperationQueue.main.addOperation {
            self.background.setContentOffset(CGPoint(x:0, y:self.descriptin!.frame.origin.y-100), animated: true)
//            self.background.scrollRectToVisible(self.descriptin.frame, animated: true)
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
            nationalID.becomeFirstResponder()
        } else if (scoreText == self.nationalID) {
            nationalID.resignFirstResponder()
            mobileNumber.becomeFirstResponder()
        } else if (scoreText == self.mobileNumber) {
            mobileNumber.resignFirstResponder()
            email.becomeFirstResponder()
        } else if (scoreText == self.email) {
            email.resignFirstResponder()
            descriptin.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        return true
    }
    
    func textViewShouldReturn(_ scoreText: UITextView) -> Bool {
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
    
    @IBAction func dobPressed(_ sender: Any) {
        self.view.endEditing(true)
        deregisterFromKeyboardNotifications()
        selectedDate = "dob"
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
        self.toolBar.isHidden = !self.toolBar.isHidden
    }
    
    @IBAction func startDatePressed(_ sender: Any) {
        self.view.endEditing(true)
        deregisterFromKeyboardNotifications()
        selectedDate = "start"
        var date = ""
        var color = ""
        if (self.startDateSelected == "") {
            date = "Insurance Start Date"
            color = "#C7C7CD"
        } else {
            date = self.startDateSelected
            color = "#000000"
        }
        self.insuranceStartDate.setTitle(date, for: .normal)
        self.insuranceStartDate.setTitleColor(UIColor().HexToColor(hexString: color, alpha: 1.0), for: .normal)
        self.datePicker.isHidden = !self.datePicker.isHidden
        self.toolBar.isHidden = !self.toolBar.isHidden
    }
    
    @IBAction func endDatePressed(_ sender: Any) {
        self.view.endEditing(true)
        deregisterFromKeyboardNotifications()
        selectedDate = "end"
        var date = ""
        var color = ""
        if (self.endDateSelected == "") {
            date = "Insurance End Date"
            color = "#C7C7CD"
        } else {
            date = self.endDateSelected
            color = "#000000"
        }
        self.insuranceEndDate.setTitle(date, for: .normal)
        self.insuranceEndDate.setTitleColor(UIColor().HexToColor(hexString: color, alpha: 1.0), for: .normal)
        self.datePicker.isHidden = !self.datePicker.isHidden
        self.toolBar.isHidden = !self.toolBar.isHidden
    }
    
    @objc @IBAction func cancelPressed(_ sender: Any) {
        registerForKeyboardNotifications()
        self.datePicker.isHidden = !self.datePicker.isHidden
        self.toolBar.isHidden = !self.toolBar.isHidden
    }
    @objc @IBAction func donePressed(_ sender: Any) {
        registerForKeyboardNotifications()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let strDate = dateFormatter.string(from: datePicker.date)
        if (selectedDate == "dob") {
            self.dateSelected = strDate
            self.dob.setTitle(self.dateSelected, for: .normal)
            self.dob.setTitleColor(UIColor().HexToColor(hexString: "#000000", alpha: 1.0), for: .normal)
        } else if (selectedDate == "start") {
            self.startDateSelected = strDate
            self.insuranceStartDate.setTitle(self.startDateSelected, for: .normal)
            self.insuranceStartDate.setTitleColor(UIColor().HexToColor(hexString: "#000000", alpha: 1.0), for: .normal)
        } else if (selectedDate == "end") {
            self.endDateSelected = strDate
            self.insuranceEndDate.setTitle(self.endDateSelected, for: .normal)
            self.insuranceEndDate.setTitleColor(UIColor().HexToColor(hexString: "#000000", alpha: 1.0), for: .normal)
        }
        self.datePicker.isHidden = !self.datePicker.isHidden
        self.toolBar.isHidden = !self.toolBar.isHidden
    }
    
    @IBAction func submit(_ sender: Any) {
        var contectTypes = ""
        let name1 = name.text ?? ""
        let nationalID1 = nationalID.text ?? ""
        let mobile = mobileNumber.text ?? ""
        let email1 = email.text ?? ""
        let desc = descriptin.text ?? ""
        if ((name1.length) <= 0 || (self.dateSelected.length) <= 0 || (nationalID1.length) <= 0 || (mobile.length) <= 0
            || (email1.length) <= 0 || (self.startDateSelected.length) <= 0 || (self.endDateSelected.length) <= 0) {
            self.alertDialog (heading: "", message: constants.allFieldsErrorMessage, result: "Error");
        } else if (!isValidEmail(email: email1)){
            self.alertDialog (heading: "", message: constants.validEmailErrorMessage, result: "Error");
        } else if (!constants.isValidMobileNumber(mobile: mobile)) {
            self.alertDialog (heading: "", message: constants.validMobileNumberError, result: "Error");
        } else {
            deregisterFromKeyboardNotifications()
            self.view.endEditing(true)
            if (!auto.isOn && !house.isOn && !life.isOn && !health.isOn) {
                self.alertDialog (heading: "", message: constants.allFieldsErrorMessage, result: "Error");
            } else {
                if (auto.isOn){
                    contectTypes = "Auto Insurance"
                }
                if (house.isOn){
                    contectTypes = "House Insurance"
                }
                if (life.isOn){
                    contectTypes = "Life/Health Insurance"
                }
                if (health.isOn){
                    contectTypes = "Others"
                }
                self.sendRemainder(actionId: "send_reminder", name: name1, insurance_type: contectTypes, date_of_birth: self.dateSelected, nationalID: nationalID1, phoneNumber: mobile, email: email1, insuranceStartDate: self.startDateSelected, insuranceEndDate: self.endDateSelected, message: desc)
                
                DispatchQueue.main.async(execute: {
                    /* Do some heavy work (you are now on a background queue) */
                    LoadingIndicatorView.show(self.constants.remainderLoading)
                });
            }
        }
    }
    
    func auto(mySwitch: UISwitch) {
        deregisterFromKeyboardNotifications()
        self.view.endEditing(true)
        self.datePicker.isHidden = true
        self.toolBar.isHidden = true
        
        auto.isOn = false
        house.isOn = false
        life.isOn = false
        health.isOn = false
        
        mySwitch.isOn = true
    }
    
    func sendRemainder(actionId: String, name: String, insurance_type: String, date_of_birth: String, nationalID: String, phoneNumber: String, email: String, insuranceStartDate: String, insuranceEndDate: String, message: String) -> Void {
        
        var params = "\(name)&national_id=\(nationalID)&start_date=\(insuranceStartDate)&end_date=\(insuranceEndDate)&mobile_no=\(phoneNumber)&date_of_birth=\(date_of_birth)&insurance_type=\(insurance_type)&email=\(email)&message=\(message)"
        let endPoint: String = {
            return "\(constants.BASE_URL)?action_id=\(actionId)&full_name="
        }()
        params = params.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let urlEndPoint = "\(endPoint)\(params)"
        
        self.webserviceManager.login(type: "single", endPoint: urlEndPoint) { (result) in
            LoadingIndicatorView.hideInMain()
            switch result {
            case .SuccessSingle( _, let message):
                self.alertDialog (heading: "", message: message, result: "Success");
            case .Error(let message):
                self.alertDialog (heading: "", message: message, result: "Success");
            default:
                self.alertDialog (heading: "", message: self.constants.errorMessage, result: "Error");
                
            }
            self.registerForKeyboardNotifications()
        }
    }
    
    func alertDialog (heading: String, message: String, result: String) {
        OperationQueue.main.addOperation {
            if (result == "Success") {
                self.name.text  = ""
                self.nationalID.text  = ""
                self.mobileNumber.text  = ""
                self.email.text  = ""
                self.descriptin.text  = ""
                self.name.placeholder  = " Your Name"
                self.nationalID.placeholder  = " National ID"
                self.mobileNumber.placeholder  = " Mobile Number"
                self.email.placeholder  = " Email"
                self.descriptin.text = "Description"
                self.descriptin.textColor = UIColor.lightGray
                self.dob.setTitle("Date of Birth", for: .normal)
                self.dob.setTitleColor(UIColor().HexToColor(hexString: "#C7C7CD", alpha: 1.0), for: .normal)
                self.insuranceStartDate.setTitle("Insurance Start Date", for: .normal)
                self.insuranceStartDate.setTitleColor(UIColor().HexToColor(hexString: "#C7C7CD", alpha: 1.0), for: .normal)
                self.insuranceEndDate.setTitle("Insurance End Date", for: .normal)
                self.insuranceEndDate.setTitleColor(UIColor().HexToColor(hexString: "#C7C7CD", alpha: 1.0), for: .normal)
                if (self.auto.isOn) {
                    self.auto.isOn = false
                }
                if (self.house.isOn) {
                    self.house.isOn = false
                }
                if (self.life.isOn) {
                    self.life.isOn = false
                }
                if (self.health.isOn) {
                    self.health.isOn = false
                }
            }
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
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
        self.nationalID.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        if (mobileNumber.isFirstResponder) {
            mobileNumber.resignFirstResponder()
            email.becomeFirstResponder()
        } else if (nationalID.isFirstResponder) {
            nationalID.resignFirstResponder()
            mobileNumber.becomeFirstResponder()
        }
    }
    
    func isValidEmail(email: String) -> Bool {
        print("validate emilId: \(email)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        return result
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
                OperationQueue.main.addOperation {
                    self.background.scrollRectToVisible(activeField.frame, animated: true)
                }
            }
        }
        if let activeText = self.descriptin {
            if (!aRect.contains(activeText.frame.origin)){
                OperationQueue.main.addOperation {
                    self.background.scrollRectToVisible(activeText.frame, animated: true)
                }
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
}
