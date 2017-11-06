//
//  PostComments.swift
//  RMS
//
//  Created by Mac Mini on 7/8/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import CoreData

class PostComments: UIViewController, IndicatorInfoProvider, UITextViewDelegate, UITextFieldDelegate {
    
    let constants = Constants();
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var comments: UITextView!
    var itemInfo: IndicatorInfo = "Post Comments"
    let sharedInstance = CoreDataManager.sharedInstance;
    let webserviceManager = WebserviceManager();
    let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        comments.delegate = self
        name.delegate = self
        subject.delegate = self
        mobileNumber.delegate = self
        comments.backgroundColor = UIColor.clear
        comments.layer.contents = UIImage(named: "comments-big")!.cgImage
        comments.text = "Comments"
        comments.textColor = UIColor.lightGray
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: 3, height: self.name.frame.size.height)
        name.leftView = paddingView
        name.leftViewMode = UITextFieldViewMode.always
        
        let paddingView1 = UIView()
        paddingView1.frame = CGRect(x: 0, y: 0, width: 3, height: self.mobileNumber.frame.size.height)
        mobileNumber.leftView = paddingView1
        mobileNumber.leftViewMode = UITextFieldViewMode.always
        
        let paddingView2 = UIView()
        paddingView2.frame = CGRect(x: 0, y: 0, width: 3, height: self.subject.frame.size.height)
        subject.leftView = paddingView2
        subject.leftViewMode = UITextFieldViewMode.always
        
        if (currentSelection.name == "ebclaims") {
            var results : [STAFF_DETAILS]
            let studentUniversityFetchRequest: NSFetchRequest<STAFF_DETAILS>  = STAFF_DETAILS.fetchRequest()
            studentUniversityFetchRequest.returnsObjectsAsFaults = false
            do {
                results = try self.managedContext.fetch(studentUniversityFetchRequest)
                let mobileNumber = results.first!.phone ?? ""
                let staffname = results.first!.member_name ?? ""
                self.mobileNumber.text = " " + mobileNumber;
                self.name.text = " " + staffname;
            } catch let error as NSError {
                print ("Could not fetch \(error), \(error.userInfo)")
            }
        } else if (currentSelection.name == "salary") {
            var results : [STAFF_DETAILS_SALARY]
            let studentUniversityFetchRequest: NSFetchRequest<STAFF_DETAILS_SALARY>  = STAFF_DETAILS_SALARY.fetchRequest()
            studentUniversityFetchRequest.returnsObjectsAsFaults = false
            do {
                results = try self.managedContext.fetch(studentUniversityFetchRequest)
                let staffname = results.first!.staffName ?? ""
                self.name.text = " " + staffname;
            } catch let error as NSError {
                print ("Could not fetch \(error), \(error.userInfo)")
            }
        } else if (currentSelection.name == "lines") {
            var results : [STAFF_DETAILS_LINES]
            let studentUniversityFetchRequest: NSFetchRequest<STAFF_DETAILS_LINES>  = STAFF_DETAILS_LINES.fetchRequest()
            studentUniversityFetchRequest.returnsObjectsAsFaults = false
            do {
                results = try self.managedContext.fetch(studentUniversityFetchRequest)
                let staffname = results.first!.staffName ?? ""
                self.name.text = " " + staffname;
            } catch let error as NSError {
                print ("Could not fetch \(error), \(error.userInfo)")
            }
        }
        hideKeyboard()
        addDoneButtonOnKeyboard()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if comments.textColor == UIColor.lightGray {
            comments.text = ""
            comments.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if comments.text.isEmpty {
            comments.text = "Comments"
            comments.textColor = UIColor.lightGray
        }
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        if (scoreText == self.name) {
            name.resignFirstResponder()
            subject.becomeFirstResponder()
        } else if (scoreText == self.subject) {
            subject.resignFirstResponder()
            mobileNumber.becomeFirstResponder()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func submit(_ sender: Any) {
        self.view.endEditing(true)
        let name1 = self.name.text ?? ""
        let subject1 = self.subject.text ?? ""
        let mobile1 = self.mobileNumber.text ?? ""
        let comments2 = self.comments.text ?? ""
        
        if ((name1.length) <= 0 || (subject1.length) <= 0 || (mobile1.length) <= 0 || (comments2.length) <= 0) {
            self.alertDialog (heading: "", message: self.constants.allFieldsErrorMessage, result: "Error");
        } else if (!constants.isValidMobileNumber(mobile: mobile1)){
            self.alertDialog (heading: "", message: self.constants.validMobileNumberError, result: "Error");
        } else {
            if (currentSelection.name == "ebclaims") {
                var results : [STAFF_DETAILS]
                let studentUniversityFetchRequest: NSFetchRequest<STAFF_DETAILS>  = STAFF_DETAILS.fetchRequest()
                studentUniversityFetchRequest.returnsObjectsAsFaults = false
                do {
                    results = try self.managedContext.fetch(studentUniversityFetchRequest)
                    let staff_id = results.first!.staff_id ?? ""
                    let member_id = results.first!.member_id ?? ""
                    let client_id = results.first!.client_id ?? ""
                    LoadingIndicatorView.show(constants.commentsLoading)
                    self.postComments(baseURL: constants.BASE_URL, actionId: "post_comments", memberId: member_id, staffID: staff_id, clientID: client_id, phoneNumber: mobile1, name: name1, subject: subject1, comments1: comments2)
                } catch let error as NSError {
                    print ("Could not fetch \(error), \(error.userInfo)")
                }
            } else if (currentSelection.name == "salary") {
                var results : [STAFF_DETAILS_SALARY]
                let studentUniversityFetchRequest: NSFetchRequest<STAFF_DETAILS_SALARY>  = STAFF_DETAILS_SALARY.fetchRequest()
                studentUniversityFetchRequest.returnsObjectsAsFaults = false
                do {
                    results = try self.managedContext.fetch(studentUniversityFetchRequest)
                    let staff_id = results.first!.staffID ?? ""
                    let client_id = results.first!.clientID ?? ""
                    LoadingIndicatorView.show(constants.commentsLoading)
                    self.postComments(baseURL: constants.BASE_URL_SALARY, actionId: "post_comments", memberId: "", staffID: staff_id, clientID: client_id, phoneNumber: mobile1, name: name1, subject: subject1, comments1: comments2)
                } catch let error as NSError {
                    print ("Could not fetch \(error), \(error.userInfo)")
                }
            } else if (currentSelection.name == "lines") {
                var results : [STAFF_DETAILS_LINES]
                let studentUniversityFetchRequest: NSFetchRequest<STAFF_DETAILS_LINES>  = STAFF_DETAILS_LINES.fetchRequest()
                studentUniversityFetchRequest.returnsObjectsAsFaults = false
                do {
                    results = try self.managedContext.fetch(studentUniversityFetchRequest)
                    let staff_id = results.first!.staffID ?? ""
                    let client_id = results.first!.clientID ?? ""
                    LoadingIndicatorView.show(constants.commentsLoading)
                    self.postComments(baseURL: constants.BASE_URL_LINES, actionId: "post_comments", memberId: "", staffID: staff_id, clientID: client_id, phoneNumber: mobile1, name: name1, subject: subject1, comments1: comments2)
                } catch let error as NSError {
                    print ("Could not fetch \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func postComments(baseURL: String, actionId: String, memberId: String, staffID: String, clientID: String, phoneNumber: String, name: String, subject: String, comments1: String) -> Void {
        let MemberName = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let Subject = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let Comments = comments1.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let PhoneNumber = phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let endPoint: String = {
            return "\(baseURL)?action_id=\(actionId)&mobile_no=\(PhoneNumber)&name=\(MemberName)&subject=\(Subject)&staff_id=\(staffID)&client_no=\(clientID)&member_id=\(memberId)&comments=\(Comments)"
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
    }
    
    func alertDialog (heading: String, message: String, result: String) {
        OperationQueue.main.addOperation {
            if (result == "Success") {
                self.name.text  = ""
                self.subject.text  = ""
                self.mobileNumber.text  = ""
                self.comments.text  = ""
                self.name.placeholder  = "Your Name"
                self.subject.placeholder  = "Subject"
                self.mobileNumber.placeholder  = "Mobile Number"
                self.comments.text = "Comments"
                self.comments.textColor = UIColor.lightGray
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
    }
    
    func doneButtonAction() {
        if (mobileNumber.isFirstResponder) {
            mobileNumber.resignFirstResponder()
            comments.becomeFirstResponder()
        }
    }
    
}
