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
        
        let img = UIImageView(frame: comments.bounds)
        img.image = UIImage(named: "comments-big")
        comments.backgroundColor = UIColor.clear
        comments.addSubview( img)
        comments.text = "Comments"
        comments.textColor = UIColor.lightGray
//        comments.selectedTextRange = comments.textRange(from: comments.beginningOfDocument, to: comments.beginningOfDocument)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func submit(_ sender: Any) {
        let name1 = self.name.text
        let subject1 = self.subject.text
        let mobile1 = self.mobileNumber.text
        let comments2 = self.comments.text
        
        if ((name1?.length)! <= 0 || (subject1?.length)! <= 0 || (mobile1?.length)! <= 0 || (comments2?.length)! <= 0) {
            self.showToast(message: "All fileds are mandatory")
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
                    LoadingIndicatorView.show("Submitting Comments...")
                    self.name.resignFirstResponder()
                    self.mobileNumber.resignFirstResponder()
                    self.subject.resignFirstResponder()
                    self.comments.resignFirstResponder()
                    self.postComments(baseURL: constants.BASE_URL, actionId: "post_comments", memberId: member_id, staffID: staff_id, clientID: client_id, phoneNumber: mobile1!, name: name1!, subject: subject1!, comments1: comments2!)
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
                    LoadingIndicatorView.show("Submitting Comments...")
                    self.name.resignFirstResponder()
                    self.mobileNumber.resignFirstResponder()
                    self.subject.resignFirstResponder()
                    self.comments.resignFirstResponder()
                    self.postComments(baseURL: constants.BASE_URL_SALARY, actionId: "post_comments", memberId: "", staffID: staff_id, clientID: client_id, phoneNumber: mobile1!, name: name1!, subject: subject1!, comments1: comments2!)
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
                    LoadingIndicatorView.show("Submitting Comments...")
                    self.name.resignFirstResponder()
                    self.mobileNumber.resignFirstResponder()
                    self.subject.resignFirstResponder()
                    self.comments.resignFirstResponder()
                    self.postComments(baseURL: constants.BASE_URL_LINES, actionId: "post_comments", memberId: "", staffID: staff_id, clientID: client_id, phoneNumber: mobile1!, name: name1!, subject: subject1!, comments1: comments2!)
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
            self.comments.text  = ""
            self.name.placeholder  = "Your Name"
            self.subject.placeholder  = "Subject"
            self.mobileNumber.placeholder  = "Mobile Number"
            self.comments.text = "Comments"
            self.comments.textColor = UIColor.lightGray
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height + 100, width: 280, height: 35))
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
