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
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS")
        do {
            let people = try managedContext.fetch(fetchRequest)
            for people in people {
                let mobileNumber = (people.value(forKey: "phone") ?? "") as! String;
                let staffname = (people.value(forKey: "member_name") ?? "") as! String;
                self.mobileNumber.text = " " + mobileNumber;
                self.name.text = " " + staffname;
                return
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
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
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS")
            do {
                let people = try managedContext.fetch(fetchRequest)
                for people in people {
                    let staff_id = (people.value(forKey: "staff_id") ?? "") as! String;
                    let member_id = (people.value(forKey: "member_id") ?? "") as! String;
                    let client_id = (people.value(forKey: "client_id") ?? "") as! String;
                    
                    DispatchQueue.main.async(execute: {
                        /* Do some heavy work (you are now on a background queue) */
                        LoadingIndicatorView.show("Submitting Comments...")
                    });
                    self.name.resignFirstResponder()
                    self.mobileNumber.resignFirstResponder()
                    self.subject.resignFirstResponder()
                    self.comments.resignFirstResponder()
                    self.postComments(actionId: "post_comments", memberId: member_id, staffID: staff_id, clientID: client_id, phoneNumber: mobile1!, name: name1!, subject: subject1!, comments1: comments2!)
                    return
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func postComments(actionId: String, memberId: String, staffID: String, clientID: String, phoneNumber: String, name: String, subject: String, comments1: String) -> Void {
        let MemberName = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let Subject = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let Comments = comments1.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let PhoneNumber = phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let POST_PARAMS = "?action_id=" + actionId + "&mobile_no="  + PhoneNumber + "&name=" + MemberName + "&subject=" + Subject + "&staff_id=" + staffID + "&client_no=" + clientID + "&member_id="  + memberId + "&comments="  + Comments;
        
        let urlString = constants.BASE_URL + POST_PARAMS;
        // Create request with URL
        let url = URL(string: urlString)!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpMethod = "POST"
        
        // Fire you request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Do whatever you would like to
            if (error != nil) {
                print (error?.localizedDescription ?? "URL Error!")
            } else {
                if let urlContent = data {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: urlContent, options: .allowFragments) as! [String:Any]
                        let status = parsedData["status"] as! String
                        
                        let message = parsedData["message"] as! String
                        
                        if (status == "success"){
                            self.alertDialog (heading: "", message: message);
                        } else if (status == "fail") {
                            DispatchQueue.main.sync(execute: {
                                /* stop the activity indicator (you are now on the main queue again) */
                                LoadingIndicatorView.hide()
                            });
                            self.alertDialog (heading: "", message: message);
                            return
                        } else {
                            DispatchQueue.main.sync(execute: {
                                /* stop the activity indicator (you are now on the main queue again) */
                                LoadingIndicatorView.hide()
                            });
                            self.alertDialog (heading: "", message: self.constants.errorMessage);
                            return
                        }
                        
                    } catch {
                        DispatchQueue.main.sync(execute: {
                            /* stop the activity indicator (you are now on the main queue again) */
                            LoadingIndicatorView.hide()
                        });
                        print("JSON processessing failed")
                        return
                    }//catch closing bracket
                }// if let closing bracket
            }//else closing bracket
        }// task closing bracket
        task.resume();
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
//            self.comments.selectedTextRange = self.comments.textRange(from: self.comments.beginningOfDocument, to: self.comments.beginningOfDocument)
            LoadingIndicatorView.hide()
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
