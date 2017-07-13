//
//  CustomAlertViewController.swift
//  RMS
//
//  Created by Mac Mini on 7/6/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import CoreData

class CustomAlertViewController : UIViewController, UITextFieldDelegate {
    let transitioner = CAVTransitioner()
    let constants = Constants();
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.transitioner
    }
    @IBOutlet weak var oldPin: UITextField!
    @IBOutlet weak var confirmPin: UITextField!
    @IBOutlet weak var newPin: UITextField!
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    @IBAction func doDismiss(_ sender:Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oldPin.delegate = self;
        confirmPin.delegate = self;
        newPin.delegate = self;
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func textField(_ oldPin: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 4
        let currentString: NSString = oldPin.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textField1(_ confirmPin: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 4
        let currentString: NSString = confirmPin.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textField2(_ newPin: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 4
        let currentString: NSString = newPin.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    @IBAction func resetPin(_ sender: Any) {
        
        DispatchQueue.main.async(execute: {
            /* Do some heavy work (you are now on a background queue) */
            LoadingIndicatorView.show("Reseting Pin...")
        });
        do {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedContext =
                appDelegate.persistentContainer.viewContext
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "MASTER_DATA")
            let people = try managedContext.fetch(fetchRequest)
            for people in people {
                let mobileNumber = (people.value(forKey: "mobileNumber") ?? "") as! String;
                let staffID = (people.value(forKey: "staffID") ?? "") as! String;
                let clientID = (people.value(forKey: "clientID") ?? "") as! String;
                let pinText = (people.value(forKey: "pin") ?? "") as! String;
                let oldPinText = oldPin.text
                let newPinText = newPin.text
                let confirmNewPinText = confirmPin.text
                if (pinText != "" && pinText == oldPinText) {
                    if (newPinText?.length == 4 && confirmNewPinText?.length == 4){
                        if (newPinText != oldPinText) {
                            if (newPinText == confirmNewPinText) {
                                if (mobileNumber != "" && staffID != ""  && clientID != "" ){
                                    resetPinCall(actionId: "reset_pin", phoneNumber: mobileNumber, pin: confirmNewPinText!, deviceID: constants.deviceID, staffID: staffID, clientID: clientID)
                                    return
                                } else {
                                    DispatchQueue.main.sync(execute: {
                                        /* stop the activity indicator (you are now on the main queue again) */
                                        LoadingIndicatorView.hide()
                                    });
                                    return
                                }
                            } else {
                                DispatchQueue.main.sync(execute: {
                                    /* stop the activity indicator (you are now on the main queue again) */
                                    LoadingIndicatorView.hide()
                                });
                                self.showToast(message: "New PIN and Confirm PIN does not match")
                                return
                                //New PIN and Confirm PIN does not match
                            }
                        } else {
                            DispatchQueue.main.sync(execute: {
                                /* stop the activity indicator (you are now on the main queue again) */
                                LoadingIndicatorView.hide()
                            });
                            self.showToast(message: "Your OLD Pin and New PIN should not be same")
                            return
                        }
                        
                    } else {
                        DispatchQueue.main.sync(execute: {
                            /* stop the activity indicator (you are now on the main queue again) */
                            LoadingIndicatorView.hide()
                        });
                        self.showToast(message: "Please Enter valid PIN Alert")
                        return
                        //Please Enter valid PIN Alert
                    }
                } else {
                    DispatchQueue.main.sync(execute: {
                        /* stop the activity indicator (you are now on the main queue again) */
                        LoadingIndicatorView.hide()
                    });
                    self.showToast(message: "Please check your OLD PIN Alert")
                    return
                    //Please check your OLD PIN Alert
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func resetPinCall(actionId: String, phoneNumber: String, pin: String, deviceID: String, staffID: String, clientID: String) -> Void {
        
        let POST_PARAMS = "?action_id=" + actionId + "&mobile_no="  + phoneNumber + "&new_pin_code=" + pin + "&device_id=" + deviceID + "&staff_id=" + staffID + "&client_no=" + clientID;
        
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
                            
                            let data = parsedData["data"] as! [String:Any]
                            for (_, _) in data {
                                let staffID = data["staff_id"] as? String ?? ""
                                let clientID = data["client_no"] as? String ?? ""
                                let change_pin = data["change_pin"] as? String ?? ""
                                self.save(phoneNumber: phoneNumber, changePin: change_pin, staffID: staffID, clientID: clientID, newPin: pin)
                                DispatchQueue.main.sync(execute: {
                                    /* stop the activity indicator (you are now on the main queue again) */
                                    LoadingIndicatorView.hide()
                                });
                                self.presentingViewController?.dismiss(animated: true)
                                self.alertDialog1(heading: "",message: message)
                                return
                            }
                        } else if (status == "fail") {
                            DispatchQueue.main.sync(execute: {
                                /* stop the activity indicator (you are now on the main queue again) */
                                LoadingIndicatorView.hide()
                            });
                            self.presentingViewController?.dismiss(animated: true)
                            self.showToast(message: message)
//                            self.alertDialog (heading: "", message: message);
                            return
                        } else {
                            DispatchQueue.main.sync(execute: {
                                /* stop the activity indicator (you are now on the main queue again) */
                                LoadingIndicatorView.hide()
                            });
                            self.showToast(message: self.constants.errorMessage)
                            self.presentingViewController?.dismiss(animated: true)
//                            self.alertDialog (heading: "", message: self.constants.errorMessage);
                            return
                        }
                        
                    } catch {
                        DispatchQueue.main.sync(execute: {
                            /* stop the activity indicator (you are now on the main queue again) */
                            LoadingIndicatorView.hide()
                        });
                        self.showToast(message: self.constants.errorMessage)
                        self.presentingViewController?.dismiss(animated: true)
                        print("JSON processessing failed")
                        return
                    }//catch closing bracket
                }// if let closing bracket
            }//else closing bracket
        }// task closing bracket
        task.resume();
    }
    
    func save(phoneNumber: String, changePin: String, staffID: String, clientID: String, newPin: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let master_data =
            NSEntityDescription.entity(forEntityName: "MASTER_DATA",
                                       in: managedContext)!
        
        let data = NSManagedObject(entity: master_data,
                                   insertInto: managedContext)
        data.setValue(newPin, forKeyPath: "pin")
        data.setValue(phoneNumber, forKeyPath: "mobileNumber")
        data.setValue(changePin, forKeyPath: "changePin")
        data.setValue(staffID, forKeyPath: "staffID")
        data.setValue(clientID, forKeyPath: "clientID")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func alertDialog1 (heading: String, message: String) {
        let appDelegate = UIApplication.shared.delegate
        OperationQueue.main.addOperation {
            LoadingIndicatorView.hide()
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "LoginController") as UIViewController
                (appDelegate?.window??.rootViewController)?.present(vc, animated: true, completion: nil)
            }))
            
            (appDelegate?.window??.rootViewController)?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height + 100, width: 280, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.systemFont(ofSize: 12)
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
