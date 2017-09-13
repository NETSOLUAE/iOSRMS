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
    @IBOutlet weak var dateTool: UIToolbar!
    
    @IBAction func selectDate(_ sender: Any) {
        self.view.endEditing(true)
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
        
        let paddingView5 = UIView()
        paddingView5.frame = CGRect(x: 0, y: 0, width: 5, height: self.name.frame.size.height)
        password.leftView = paddingView5
        password.leftViewMode = UITextFieldViewMode.always
        
        let paddingView6 = UIView()
        paddingView6.frame = CGRect(x: 0, y: 0, width: 5, height: self.name.frame.size.height)
        confirmPassword.leftView = paddingView6
        confirmPassword.leftViewMode = UITextFieldViewMode.always
        
//        let date = Date.init(timeIntervalSinceNow: 1)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        let strDate = dateFormatter.string(from: date)
//        self.dateSelected = strDate
//        self.dob.setTitle(self.dateSelected, for: .normal)
//        self.dob.setTitleColor(UIColor().HexToColor(hexString: "#000000", alpha: 1.0), for: .normal)
        self.datePicker.maximumDate = Date()
        
        self.datePicker.backgroundColor = UIColor().HexToColor(hexString: "#EBEBEB", alpha: 1.0)
        self.dateTool.backgroundColor = UIColor().HexToColor(hexString: "#EBEBEB", alpha: 1.0)
        addDoneButtonOnKeyboard()
        hideKeyboard()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        } else if (scoreText == self.nationalId) {
            nationalId.resignFirstResponder()
            password.becomeFirstResponder()
        }  else if (scoreText == self.password) {
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
    
    @IBAction func submit(_ sender: Any) {
        self.view.endEditing(true)
        let name1 = name.text ?? ""
        let mobile = mobileNumber.text ?? ""
        let companyName = self.companyName.text ?? ""
        let email1 = email.text ?? ""
        let nationalId1 = nationalId.text ?? ""
        let password1 = password.text ?? ""
        let confirmPassword1 = confirmPassword.text ?? ""
        if ((name1.length) <= 0 || (mobile.length) <= 0 || (self.dateSelected.length) <= 0 || (companyName.length) <= 0 || (companyName.length) <= 0
             || (email1.length) <= 0 || (nationalId1.length) <= 0 || (password1.length) <= 0 || (confirmPassword1.length) <= 0) {
            self.showToast(message: "All fileds are mandatory")
        } else if (password1 != confirmPassword1){
            self.alertDialog (heading: "", message: "Entered Password and Confirm Password does not match");
        } else if (!isValidEmail(email: email1)){
            self.alertDialog (heading: "", message: "Please Enter Valid Email Address");
        } else if ((mobile.length) < 11) {
            self.alertDialog (heading: "", message: "Please enter valid mobile number");
        } else {
            self.sendRegistration(actionId: "new_registration", name: name1, dob: self.dateSelected, phoneNumber: mobile, companyName: companyName, email1: email1, nationalId1: nationalId1, password1: password1)
        }
    }
    
    func sendRegistration(actionId: String, name: String, dob: String, phoneNumber: String, companyName: String, email1: String, nationalId1: String, password1: String) -> Void {
        
        let endPoint1: String = {
            return "\(constants.BASE_URL)?action_id=\(actionId)&mobile_no=\(phoneNumber)&full_name=\(name)&date_of_birth=\(dob)&company_name=\(companyName)&national_id=\(nationalId1)&email=\(email1)&password=\(password1)"
        }()
        let endPoint = NSString(format: endPoint1 as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        self.webserviceManager.login(type: "single", endPoint: endPoint) { (result) in
            LoadingIndicatorView.hideInMain()
            switch result {
            case .SuccessSingle( _, let message):
                self.alertDialog (heading: "", message: message);
            case .Error(let message):
                self.alertDialog (heading: "", message: message);
            default:
                self.alertDialog (heading: "", message: self.constants.errorMessage);
                
            }
        }
    }

    func alertDialog (heading: String, message: String) {
        OperationQueue.main.addOperation {
            self.name.text  = ""
            self.mobileNumber.text  = ""
            self.companyName.text  = ""
            self.email.text  = ""
            self.nationalId.text  = ""
            self.password.text  = ""
            self.confirmPassword.text  = ""
            self.name.placeholder  = "Your Name"
            self.mobileNumber.placeholder  = "Mobile Number"
            self.companyName.placeholder = "Company Name"
            self.email.placeholder = "Email"
            self.nationalId.placeholder  = "National ID"
            self.password.placeholder  = "Password"
            self.confirmPassword.placeholder  = "Confirm Password"
            self.dob.setTitle("Date of Birth", for: .normal)
            self.dob.setTitleColor(UIColor().HexToColor(hexString: "#C7C7CD", alpha: 1.0), for: .normal)
            
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height, width: 280, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
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
    }
    
    func doneButtonAction() {
        if (mobileNumber.isFirstResponder) {
            mobileNumber.resignFirstResponder()
            companyName.becomeFirstResponder()
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
