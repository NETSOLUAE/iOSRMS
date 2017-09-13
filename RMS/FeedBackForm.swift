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
    var questionChecked : Bool = false
    var suggestionChecked : Bool = false
    var problemChecked : Bool = false
    var connectChecked : Bool = false
    
    @IBOutlet weak var background: UIScrollView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var descriptin: UITextView!
    @IBOutlet weak var question: UISwitch!
    @IBOutlet weak var suggestion: UISwitch!
    @IBOutlet weak var problem: UISwitch!
    @IBOutlet weak var connect: UISwitch!
    
    override func viewDidLoad() {
        background.backgroundColor = UIColor(patternImage: UIImage(named: "background-1")!)
        
        let img = UIImageView(frame: descriptin.bounds)
        img.image = UIImage(named: "comments-big")
        descriptin.delegate = self
        name.delegate = self
        subject.delegate = self
        mobileNumber.delegate = self
        descriptin.backgroundColor = UIColor.clear
        descriptin.addSubview( img)
        descriptin.text = "Description"
        descriptin.textColor = UIColor.lightGray
//        descriptin.selectedTextRange = descriptin.textRange(from: descriptin.beginningOfDocument, to: descriptin.beginningOfDocument)
        
        question.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        suggestion.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        problem.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        connect.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        question.addTarget(self, action: #selector(self.switchIsChanged(mySwitch:)), for: UIControlEvents.valueChanged)
        suggestion.addTarget(self, action: #selector(self.suggestion(mySwitch:)), for: UIControlEvents.valueChanged)
        problem.addTarget(self, action: #selector(self.problem(mySwitch:)), for: UIControlEvents.valueChanged)
        connect.addTarget(self, action: #selector(self.connect(mySwitch:)), for: UIControlEvents.valueChanged)
        
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
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        self.view.endEditing(true)
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
    
    @IBAction func submit(_ sender: Any) {
        var contectTypes = ""
        let name1 = name.text
        let subject1 = subject.text
        let desc = descriptin.text
        let mobile = mobileNumber.text
        if ((name1?.length)! <= 0 || (subject1?.length)! <= 0 || (mobile?.length)! <= 0 || (desc?.length)! <= 0) {
            self.showToast(message: "All fileds are mandatory")
        } else {
            if (!questionChecked && !suggestionChecked && !problemChecked && !connectChecked) {
                self.showToast(message: "All fileds are mandatory")
            } else {
                
                DispatchQueue.main.async(execute: {
                    /* Do some heavy work (you are now on a background queue) */
                    LoadingIndicatorView.show("Submitting Your Feedback...")
                });
                if (questionChecked){
                    contectTypes = contectTypes + "Question"
                }
                if (suggestionChecked){
                    contectTypes = contectTypes + ",Suggestion"
                }
                if (problemChecked){
                    contectTypes = contectTypes + ",Problem"
                }
                if (connectChecked){
                    contectTypes = contectTypes + ",Contact"
                }
                self.name.resignFirstResponder()
                self.mobileNumber.resignFirstResponder()
                self.subject.resignFirstResponder()
                self.descriptin.resignFirstResponder()
                self.sendFeedback(actionId: "post_feedback", name: name1!, phoneNumber: mobile!, contactType: contectTypes, subject: subject1!, description: desc!)
            }
        }
    }
    func switchIsChanged(mySwitch: UISwitch) {
        if mySwitch.isOn {
            questionChecked = true
        } else {
            questionChecked = false
        }
    }
    
    func suggestion(mySwitch: UISwitch) {
        if mySwitch.isOn {
            suggestionChecked = true
        } else {
            suggestionChecked = false
        }
    }
    
    func problem(mySwitch: UISwitch) {
        if mySwitch.isOn {
            problemChecked = true
        } else {
            problemChecked = false
        }
    }
    
    func connect(mySwitch: UISwitch) {
        if mySwitch.isOn {
            connectChecked = true
        } else {
            connectChecked = false
        }
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
            self.subject.text  = ""
            self.mobileNumber.text  = ""
            self.descriptin.text  = ""
            self.name.placeholder  = "Your Name"
            self.subject.placeholder  = "Subject"
            self.mobileNumber.placeholder  = "Mobile Number"
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
}
