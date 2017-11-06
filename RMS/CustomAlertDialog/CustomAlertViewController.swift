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
    var isEB = false;
    let transitioner = CAVTransitioner()
    let constants = Constants();
    let sharedInstance = CoreDataManager.sharedInstance;
    let webserviceManager = WebserviceManager();
    let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.transitioner
    }
    @IBOutlet weak var oldPin: UITextField!
    @IBOutlet weak var confirmPin: UITextField!
    @IBOutlet weak var newPin: UITextField!
    @IBOutlet weak var heading: UILabel!
    
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
        
        if (isEB) {
            heading.text = "Reset Password"
            oldPin.placeholder = "Enter Your Old Password"
            confirmPin.placeholder = "Confirm Your New Password"
            newPin.placeholder = "Enter Your New Password"
        }
        
        hideKeyboard()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ oldPin: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if (!isEB) {
            let maxLength = 4
            let currentString: NSString = oldPin.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else {
            return ((oldPin.text?.length) != nil)
        }
    }
    
    func textField1(_ confirmPin: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if (!isEB) {
            let maxLength = 4
            let currentString: NSString = confirmPin.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else {
            return ((confirmPin.text?.length) != nil)
        }
    }
    
    func textField2(_ newPin: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if (!isEB) {
            let maxLength = 4
            let currentString: NSString = newPin.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else {
            return ((newPin.text?.length) != nil)
        }
    }
    
    @IBAction func resetPin(_ sender: Any) {
        self.oldPin.resignFirstResponder()
        self.confirmPin.resignFirstResponder()
        self.newPin.resignFirstResponder()
        if (isEB) {
            LoadingIndicatorView.show("Reseting Password...")
        } else {
            LoadingIndicatorView.show("Reseting Pin...")
        }
        if (currentSelection.name == "ebclaims") {
            var results : [MASTER_DATA]
            let masterDataFetchRequest: NSFetchRequest<MASTER_DATA>  = MASTER_DATA.fetchRequest()
            masterDataFetchRequest.returnsObjectsAsFaults = false
            do {
                results = try managedContext.fetch(masterDataFetchRequest)
                let mobileNumber = results.first!.mobileNumber ?? ""
                let staffID = results.first!.staffID ?? ""
                let clientID = results.first!.clientID ?? ""
                let pinText = results.first!.pin ?? ""
                let oldPinText = oldPin.text ?? ""
                let newPinText = newPin.text ?? ""
                let confirmNewPinText = confirmPin.text ?? ""
                if (pinText != "" && pinText == oldPinText) {
                    if (newPinText.length > 5 && confirmNewPinText.length > 5){
                        if (newPinText != oldPinText) {
                            if (newPinText == confirmNewPinText) {
                                if (mobileNumber != "" && staffID != ""  && clientID != "" ){
                                    resetPinCall(actionId: "reset_pin_new", phoneNumber: mobileNumber, pin: confirmNewPinText, deviceID: constants.deviceID, staffID: staffID, clientID: clientID)
                                    return
                                } else {
                                    LoadingIndicatorView.hideInMain()
                                    return
                                }
                            } else {
                                LoadingIndicatorView.hideInMain()
                                self.showToast(message: "New Password and Confirm Password does not match")
                                return
                            }
                        } else {
                            LoadingIndicatorView.hideInMain()
                            self.showToast(message: "Your OLD Password and New Password should not be same")
                            return
                        }
                    } else {
                        LoadingIndicatorView.hideInMain()
                        self.showToast(message: "Password should be more than 5 characters")
                        return
                    }
                } else {
                    LoadingIndicatorView.hideInMain()
                    self.showToast(message: "Please check your OLD Password")
                    return
                }
            } catch let error as NSError {
                print ("Could not fetch \(error), \(error.userInfo)")
            }
        } else if (currentSelection.name == "salary") {
            
            var results : [MASTER_DATA_SALARY]
            let masterDataFetchRequest: NSFetchRequest<MASTER_DATA_SALARY>  = MASTER_DATA_SALARY.fetchRequest()
            masterDataFetchRequest.returnsObjectsAsFaults = false
            do {
                results = try managedContext.fetch(masterDataFetchRequest)
                let nationalID = results.first!.nationalID ?? ""
                let staffID = results.first!.staffID ?? ""
                let clientID = results.first!.clientID ?? ""
                let pinText = results.first!.pin ?? ""
                let oldPinText = oldPin.text ?? ""
                let newPinText = newPin.text ?? ""
                let confirmNewPinText = confirmPin.text ?? ""
                if (pinText != "" && pinText == oldPinText) {
                    if (newPinText.length == 4 && confirmNewPinText.length == 4){
                        if (newPinText != oldPinText) {
                            if (newPinText == confirmNewPinText) {
                                if (nationalID != "" && staffID != ""  && clientID != "" ){
                                    resetPinCall(actionId: "reset_pin", phoneNumber: nationalID, pin: confirmNewPinText, deviceID: constants.deviceID, staffID: staffID, clientID: clientID)
                                    return
                                } else {
                                    LoadingIndicatorView.hideInMain()
                                    return
                                }
                            } else {
                                LoadingIndicatorView.hideInMain()
                                self.showToast(message: "New PIN and Confirm PIN does not match")
                                return
                            }
                        } else {
                            LoadingIndicatorView.hideInMain()
                            self.showToast(message: "Your OLD Pin and New PIN should not be same")
                            return
                        }
                    } else {
                        LoadingIndicatorView.hideInMain()
                        self.showToast(message: "Please Enter valid PIN")
                        return
                    }
                } else {
                    LoadingIndicatorView.hideInMain()
                    self.showToast(message: "Please check your OLD PIN")
                    return
                }
            } catch let error as NSError {
                print ("Could not fetch \(error), \(error.userInfo)")
            }
        } else if (currentSelection.name == "lines") {
            
            var results : [MASTER_DATA_LINES]
            let masterDataFetchRequest: NSFetchRequest<MASTER_DATA_LINES>  = MASTER_DATA_LINES.fetchRequest()
            masterDataFetchRequest.returnsObjectsAsFaults = false
            do {
                results = try managedContext.fetch(masterDataFetchRequest)
                let nationalID = results.first!.nationalID ?? ""
                let staffID = results.first!.staffID ?? ""
                let clientID = results.first!.clientID ?? ""
                let pinText = results.first!.pin ?? ""
                let oldPinText = oldPin.text ?? ""
                let newPinText = newPin.text ?? ""
                let confirmNewPinText = confirmPin.text ?? ""
                if (pinText != "" && pinText == oldPinText) {
                    if (newPinText.length == 4 && confirmNewPinText.length == 4){
                        if (newPinText != oldPinText) {
                            if (newPinText == confirmNewPinText) {
                                if (nationalID != "" && staffID != ""  && clientID != "" ){
                                    resetPinCall(actionId: "reset_pin", phoneNumber: nationalID, pin: confirmNewPinText, deviceID: constants.deviceID, staffID: staffID, clientID: clientID)
                                    return
                                } else {
                                    LoadingIndicatorView.hideInMain()
                                    return
                                }
                            } else {
                                LoadingIndicatorView.hideInMain()
                                self.showToast(message: "New PIN and Confirm PIN does not match")
                                return
                            }
                        } else {
                            LoadingIndicatorView.hideInMain()
                            self.showToast(message: "Your OLD Pin and New PIN should not be same")
                            return
                        }
                    } else {
                        LoadingIndicatorView.hideInMain()
                        self.showToast(message: "Please Enter valid PIN")
                        return
                    }
                } else {
                    LoadingIndicatorView.hideInMain()
                    self.showToast(message: "Please check your OLD PIN")
                    return
                }
            } catch let error as NSError {
                print ("Could not fetch \(error), \(error.userInfo)")
            }
        }
    }
    
    func resetPinCall(actionId: String, phoneNumber: String, pin: String, deviceID: String, staffID: String, clientID: String) -> Void {
        var params = ""
        if (currentSelection.name == "ebclaims") {
            params = "\(constants.BASE_URL)?action_id=\(actionId)&mobile_no=\(phoneNumber)&";
        } else if (currentSelection.name == "salary") {
            params = "\(constants.BASE_URL_SALARY)?action_id=\(actionId)&national_id=\(phoneNumber)&";
        } else if (currentSelection.name == "lines") {
            params = "\(constants.BASE_URL_LINES)?action_id=\(actionId)&national_id=\(phoneNumber)&";
        }
        let endPoint: String = {
            return "\(params)new_pin_code=\(pin)&device_id=\(deviceID)&staff_id=\(staffID)&client_no=\(clientID)"
        }()
        
        self.webserviceManager.login(type: "single", endPoint: endPoint) { (result) in
            self.presentingViewController?.dismiss(animated: true)
            switch result {
            case .SuccessSingle(let data, let message):
                if (currentSelection.name == "ebclaims") {
                    self.sharedInstance.clearMasterData()
                    self.sharedInstance.saveInMasterDataWith(phoneNumber: phoneNumber, pin: pin, array: [data])
                } else if (currentSelection.name == "salary") {
                    self.sharedInstance.clearMasterDataSalary()
                    self.sharedInstance.saveInMasterDataSalaryWith(nationalId: phoneNumber, pin: pin, array: [data])
                } else if (currentSelection.name == "lines") {
                    self.sharedInstance.clearMasterDataLines()
                    self.sharedInstance.saveInMasterDataLinesWith(nationalId: phoneNumber, pin: pin, array: [data])
                }
                self.alertDialog1(heading: "",message: message)
            case .Error(let message):
                LoadingIndicatorView.hideInMain()
                self.alertDialog1(heading: "",message: message)
            default:
                self.showToast(message: self.constants.errorMessage)
                LoadingIndicatorView.hideInMain()
            }
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
