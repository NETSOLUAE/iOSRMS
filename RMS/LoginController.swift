 //
//  LoginController.swift
//  RMS
//
//  Created by Mac Mini on 6/28/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import CoreData

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pinHeading: UITextView!
    @IBOutlet weak var heading: UITextView!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginAction: UIButton!
    @IBOutlet weak var pin1: UITextField!
    @IBOutlet weak var pin3: UITextField!
    @IBOutlet weak var pin2: UITextField!
    @IBOutlet weak var pin4: UITextField!
    @IBOutlet weak var forget: UILabel!
    @IBOutlet weak var forgetPassword: UILabel!
    @IBOutlet weak var registerNow: UIButton!
    
    var results : [MASTER_DATA] = []
    var resultsSalary : [MASTER_DATA_SALARY] = []
    var resultsLines : [MASTER_DATA_LINES] = []
    let constants = Constants();
    let webserviceManager = WebserviceManager();
    let sharedInstance = CoreDataManager.sharedInstance;
    let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: MASTER_DATA.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "changePin", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self as? NSFetchedResultsControllerDelegate
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pin1.delegate = self;
        pin2.delegate = self;
        pin3.delegate = self;
        pin4.delegate = self;
        password.delegate = self;
        
        pin1.textAlignment = NSTextAlignment.center;
        pin2.textAlignment = NSTextAlignment.center;
        pin3.textAlignment = NSTextAlignment.center;
        pin4.textAlignment = NSTextAlignment.center;
        
        pin1.isSecureTextEntry = true
        pin2.isSecureTextEntry = true
        pin3.isSecureTextEntry = true
        pin4.isSecureTextEntry = true
        password.isSecureTextEntry = true
        
        if (currentSelection.name == "ebclaims") {
            heading.text = "Mobile Number"
            pin1.isHidden = true
            pin2.isHidden = true
            pin3.isHidden = true
            pin4.isHidden = true
            password.isHidden = false
            forget.isHidden = true
            forgetPassword.isHidden = false
            registerNow.isHidden = false
        } else if (currentSelection.name == "salary" || currentSelection.name == "lines" ) {
            heading.text = "National ID"
            pin1.isHidden = false
            pin2.isHidden = false
            pin3.isHidden = false
            pin4.isHidden = false
            password.isHidden = true
            forget.isHidden = false
            forget.isUserInteractionEnabled = true
            forgetPassword.isHidden = true
            registerNow.isHidden = true
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        forget.addGestureRecognizer(tap)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        forgetPassword.addGestureRecognizer(tap1)
        
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedhResultController.sections?[0].numberOfObjects))")
        } catch let error  {
            print("ERROR: \(error)")
        }
        
        hideKeyboard()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    public func resetPinAlert () {
        OperationQueue.main.addOperation {
            let vc = CustomAlertForget()
            self.present(vc, animated: true)
        }
    }
    
    func tapFunction(sender:UITapGestureRecognizer) {
        if (self.phoneNumber.text! as String != ""){
            if (currentSelection.name == "ebclaims") {
                resetPinAlert()
//                var results : [MASTER_DATA]
//                let masterDataFetchRequest: NSFetchRequest<MASTER_DATA>  = MASTER_DATA.fetchRequest()
//                masterDataFetchRequest.returnsObjectsAsFaults = false
//                do {
//                    results = try managedContext.fetch(masterDataFetchRequest)
//                    if (results.count > 0) {
//                        let mobileNumber = results.first!.mobileNumber ?? ""
//                        let staffID = results.first!.staffID ?? ""
//                        let clientID = results.first!.clientID ?? ""
//                        self.sendSms(params: "\(constants.BASE_URL)?action_id=send_sms&mobile_no=\(mobileNumber)&staff_id=\(staffID)&client_no=\(clientID)")
//                    }
//                } catch let error as NSError {
//                    print ("Could not fetch \(error), \(error.userInfo)")
//                }
            } else if (currentSelection.name == "salary") {
                var results : [MASTER_DATA_SALARY]
                let masterDataFetchRequest: NSFetchRequest<MASTER_DATA_SALARY>  = MASTER_DATA_SALARY.fetchRequest()
                masterDataFetchRequest.returnsObjectsAsFaults = false
                do {
                    results = try managedContext.fetch(masterDataFetchRequest)
                    if (results.count > 0) {
                        let mobileNumber = results.first!.nationalID ?? ""
                        let staffID = results.first!.staffID ?? ""
                        let clientID = results.first!.clientID ?? ""
                        self.sendSms(params: "\(constants.BASE_URL_SALARY)?action_id=send_sms&national_id=\(mobileNumber)&staff_id=\(staffID)&client_no=\(clientID)")
                    }
                } catch let error as NSError {
                    print ("Could not fetch \(error), \(error.userInfo)")
                }
            } else if (currentSelection.name == "lines" ) {
                var results : [MASTER_DATA_LINES]
                let masterDataFetchRequest: NSFetchRequest<MASTER_DATA_LINES>  = MASTER_DATA_LINES.fetchRequest()
                masterDataFetchRequest.returnsObjectsAsFaults = false
                do {
                    results = try managedContext.fetch(masterDataFetchRequest)
                    if (results.count > 0) {
                        let mobileNumber = results.first!.nationalID ?? ""
                        let staffID = results.first!.staffID ?? ""
                        let clientID = results.first!.clientID ?? ""
                        self.sendSms(params: "\(constants.BASE_URL_LINES)?action_id=send_sms&national_id=\(mobileNumber)&staff_id=\(staffID)&client_no=\(clientID)")
                    }
                } catch let error as NSError {
                    print ("Could not fetch \(error), \(error.userInfo)")
                }
            }
        } else {
//            alertDialog (heading: "Alert", message: "Please Enter your Phone Number");
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (currentSelection.name == "ebclaims") {
            let masterDataFetchRequest: NSFetchRequest<MASTER_DATA>  = MASTER_DATA.fetchRequest()
            masterDataFetchRequest.returnsObjectsAsFaults = false
            do {
                results = try managedContext.fetch(masterDataFetchRequest)
                if (results.count > 0) {
                    let mobileNumber = results.first!.mobileNumber
                    if (mobileNumber != ""){
                        self.pinHeading.text = "Enter your Password"
                        self.phoneNumber.text = mobileNumber;
                        self.phoneNumber.isUserInteractionEnabled = false;
                        password.becomeFirstResponder();
                    } else {
                        self.pinHeading.text = "Enter your Password"
                        phoneNumber.becomeFirstResponder();
                    }
                } else {
                    self.pinHeading.text = "Enter your Password"
                    phoneNumber.becomeFirstResponder();
                }
            } catch let error as NSError {
                print ("Could not fetch \(error), \(error.userInfo)")
            }
        } else if (currentSelection.name == "salary") {
            let masterDataFetchRequest: NSFetchRequest<MASTER_DATA_SALARY>  = MASTER_DATA_SALARY.fetchRequest()
            masterDataFetchRequest.returnsObjectsAsFaults = false
            do {
                resultsSalary = try managedContext.fetch(masterDataFetchRequest)
                if (resultsSalary.count > 0) {
                    let nationalID = resultsSalary.first!.nationalID ?? ""
                    if (nationalID != ""){
                        self.pinHeading.text = "Enter your Secret PIN"
                        self.phoneNumber.text = nationalID;
                        self.phoneNumber.isUserInteractionEnabled = false;
                        pin1.becomeFirstResponder();
                    } else {
                        self.pinHeading.text = "Setup your Secret PIN"
                        phoneNumber.becomeFirstResponder();
                    }
                } else {
                    self.pinHeading.text = "Setup your Secret PIN"
                    phoneNumber.becomeFirstResponder();
                }
            } catch let error as NSError {
                print ("Could not fetch \(error), \(error.userInfo)")
            }
        } else if (currentSelection.name == "lines" ) {
            let masterDataFetchRequest: NSFetchRequest<MASTER_DATA_LINES>  = MASTER_DATA_LINES.fetchRequest()
            masterDataFetchRequest.returnsObjectsAsFaults = false
            do {
                resultsLines = try managedContext.fetch(masterDataFetchRequest)
                if (resultsLines.count > 0) {
                    let nationalID = resultsLines.first!.nationalID ?? ""
                    if (nationalID != ""){
                        self.pinHeading.text = "Enter your Secret PIN"
                        self.phoneNumber.text = nationalID;
                        self.phoneNumber.isUserInteractionEnabled = false;
                        pin1.becomeFirstResponder();
                    } else {
                        self.pinHeading.text = "Setup your Secret PIN"
                        phoneNumber.becomeFirstResponder();
                    }
                } else {
                    self.pinHeading.text = "Setup your Secret PIN"
                    phoneNumber.becomeFirstResponder();
                }
            } catch let error as NSError {
                print ("Could not fetch \(error), \(error.userInfo)")
            }
        }
        
    }
    
    @IBAction func login(_ sender: UIButton) {
        let phoneText: NSString = self.phoneNumber.text! as NSString;
        if (currentSelection.name == "ebclaims") {
            let passwordText: NSString = self.password.text! as NSString;
            
            if (phoneText != ""){
                if (passwordText != "") {
                    /* start the activity indicator (you are now on the main queue) */
                    LoadingIndicatorView.show("Authenticating...")
                    self.password.resignFirstResponder()
                    if (currentSelection.name == "ebclaims") {
                        var staffID = ""
                        var clientID = ""
                        if (results.count > 0) {
                            staffID = results.first!.staffID ?? ""
                            clientID = results.first!.clientID ?? ""
                        }
                        loginCall(actionId: "login", phoneNumber: phoneText as String, pin: passwordText as String, deviceID: constants.deviceID , staffID: staffID , clientID: clientID)
                    }
                } else {
                    alertDialog (heading: "Alert", message: "Please Enter Password");
                }
            } else {
                alertDialog (heading: "Alert", message: "Please Enter your Phone Number");
            }
        } else {
            let pin1Text: NSString = self.pin1.text! as NSString;
            let pin2Text: NSString = self.pin2.text! as NSString;
            let pin3Text: NSString = self.pin3.text! as NSString;
            let pin4Text: NSString = self.pin4.text! as NSString;
            
            if (phoneText != ""){
                if (pin1Text != "" && pin2Text != "" && pin3Text != "" && pin4Text != "") {
                    let pin = self.pin1.text! + self.pin2.text! + self.pin3.text! + self.pin4.text!;
                    /* start the activity indicator (you are now on the main queue) */
                    LoadingIndicatorView.show("Authenticating...")
                    self.pin1.resignFirstResponder()
                    self.pin2.resignFirstResponder()
                    self.pin3.resignFirstResponder()
                    self.pin4.resignFirstResponder()
                    if (currentSelection.name == "ebclaims") {
                        var staffID = ""
                        var clientID = ""
                        if (results.count > 0) {
                            staffID = results.first!.staffID ?? ""
                            clientID = results.first!.clientID ?? ""
                        }
                        loginCall(actionId: "login", phoneNumber: phoneText as String, pin: pin, deviceID: constants.deviceID , staffID: staffID , clientID: clientID)
                    } else if (currentSelection.name == "salary") {
                        var staffIDSalary = ""
                        var clientIDSalary = ""
                        if (resultsSalary.count > 0) {
                            staffIDSalary = resultsSalary.first!.staffID ?? ""
                            clientIDSalary = resultsSalary.first!.clientID ?? ""
                        }
                        loginCall(actionId: "login", phoneNumber: phoneText as String, pin: pin, deviceID: constants.deviceID , staffID: staffIDSalary , clientID: clientIDSalary)
                    } else if (currentSelection.name == "lines") {
                        var staffIDSalary = ""
                        var clientIDSalary = ""
                        if (resultsLines.count > 0) {
                            staffIDSalary = resultsLines.first!.staffID ?? ""
                            clientIDSalary = resultsLines.first!.clientID ?? ""
                        }
                        loginCall(actionId: "login", phoneNumber: phoneText as String, pin: pin, deviceID: constants.deviceID , staffID: staffIDSalary , clientID: clientIDSalary)
                    }
                } else {
                    alertDialog (heading: "Alert", message: "Please Enter Valid PIN");
                }
            } else {
                alertDialog (heading: "Alert", message: "Please Enter your National ID");
            }
        }
    }
    
    @IBAction func pin1Editing(_ sender: Any) {
        if (self.pin1.text!.characters.count == 1) {
            self.pin2.becomeFirstResponder();
        }
    }
    
    @IBAction func pin2Editing(_ sender: Any) {
        if (self.pin2.text!.characters.count == 1) {
            self.pin3.becomeFirstResponder();
        } else if (self.pin2.text!.characters.count == 0) {
            self.pin1.becomeFirstResponder();
        }

    }
    
    @IBAction func pin3Editing(_ sender: Any) {
        if (self.pin3.text!.characters.count == 1) {
            self.pin4.becomeFirstResponder();
        } else if (self.pin3.text!.characters.count == 0) {
            self.pin2.becomeFirstResponder();
        }
    }
    
    @IBAction func pin4Editing(_ sender: Any) {
        if (self.pin4.text!.characters.count == 0) {
            self.pin3.becomeFirstResponder();
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if (textField == self.pin1) {
            let maxLength = 1
            let currentString: NSString = pin1.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else if (textField == self.pin2) {
            let maxLength = 1
            let currentString: NSString = pin2.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else if (textField == self.pin3) {
            let maxLength = 1
            let currentString: NSString = pin3.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else if (textField == self.pin4) {
            let maxLength = 1
            let currentString: NSString = pin4.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else {
            return true
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if (self.pin4.text?.length == 0) {
            self.pin3.becomeFirstResponder();
        } else if (self.pin3.text?.length == 0) {
            self.pin2.becomeFirstResponder();
        } else if (self.pin2.text?.length == 0) {
            self.pin1.becomeFirstResponder();
        }
        return true
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func sendSms(params: String) -> Void {
        LoadingIndicatorView.show("Sending SMS....")
        self.webserviceManager.login(type: "single", endPoint: params) { (result) in
            switch result {
            case .SuccessSingle( _, let message):
                LoadingIndicatorView.hideInMain()
                self.alertDialog (heading: "", message: message);
            case .Error(let message):
                LoadingIndicatorView.hideInMain()
                self.alertDialog (heading: "", message: message);
            default:
                LoadingIndicatorView.hideInMain()
                
            }
        }
    }
    
    func loginCall(actionId: String, phoneNumber: String, pin: String, deviceID: String, staffID: String, clientID: String) -> Void {
        var params = "";
        if (currentSelection.name == "ebclaims") {
            params = "\(constants.BASE_URL)?action_id=login_new&mobile_no=\(phoneNumber)&";
        } else if (currentSelection.name == "salary") {
            params = "\(constants.BASE_URL_SALARY)?action_id=login&national_id=\(phoneNumber)&";
        } else if (currentSelection.name == "lines") {
            params = "\(constants.BASE_URL_LINES)?action_id=login&national_id=\(phoneNumber)&";
        }
        let endPoint: String = {
            if (currentSelection.name == "ebclaims") {
                return "\(params)password=\(pin)&staff_id=\(staffID)&client_no=\(clientID)"
            } else {
                return "\(params)pin_code=\(pin)&device_id=\(deviceID)&staff_id=\(staffID)&client_no=\(clientID)"
            }
        }()
        
        self.webserviceManager.login(type: "single", endPoint: endPoint) { (result) in
            switch result {
            case .SuccessSingle(let data, _):
                if (actionId == "login") {
                    if (currentSelection.name == "ebclaims") {
                        self.sharedInstance.clearMasterData()
                        self.sharedInstance.saveInMasterDataWith(phoneNumber: phoneNumber, pin: pin, array: [data])
                        var results : [MASTER_DATA]
                        let studentUniversityFetchRequest: NSFetchRequest<MASTER_DATA>  = MASTER_DATA.fetchRequest()
                        studentUniversityFetchRequest.returnsObjectsAsFaults = false
                        do {
                            results = try self.managedContext.fetch(studentUniversityFetchRequest)
                            let mobileNumber = results.first!.mobileNumber
                            let staffID = results.first!.staffID
                            let clientID = results.first!.clientID
                            
                            if (mobileNumber != "" && staffID != ""  && clientID != "" ){
                                self.staffDetails(actionId: "staff_details", phoneNumber: mobileNumber!, staffID: staffID!, clientID: clientID!)
                                return
                            } else {
                                LoadingIndicatorView.hideInMain()
                                return
                            }
                        } catch let error as NSError {
                            print ("Could not fetch \(error), \(error.userInfo)")
                        }
                    } else if (currentSelection.name == "salary") {
                        self.sharedInstance.clearMasterDataSalary()
                        self.sharedInstance.saveInMasterDataSalaryWith(nationalId: phoneNumber, pin: pin, array: [data])
                        var results : [MASTER_DATA_SALARY]
                        let studentUniversityFetchRequest: NSFetchRequest<MASTER_DATA_SALARY>  = MASTER_DATA_SALARY.fetchRequest()
                        studentUniversityFetchRequest.returnsObjectsAsFaults = false
                        do {
                            results = try self.managedContext.fetch(studentUniversityFetchRequest)
                            let nationalId = results.first!.nationalID
                            
                            if (nationalId != ""){
                                self.policyDetails(actionId: "policies", nationalId: nationalId!)
                                return
                            } else {
                                LoadingIndicatorView.hideInMain()
                                return
                            }
                        } catch let error as NSError {
                            print ("Could not fetch \(error), \(error.userInfo)")
                        }
                    } else if (currentSelection.name == "lines") {
                        self.sharedInstance.clearMasterDataLines()
                        self.sharedInstance.saveInMasterDataLinesWith(nationalId: phoneNumber, pin: pin, array: [data])
                        var results : [MASTER_DATA_LINES]
                        let studentUniversityFetchRequest: NSFetchRequest<MASTER_DATA_LINES>  = MASTER_DATA_LINES.fetchRequest()
                        studentUniversityFetchRequest.returnsObjectsAsFaults = false
                        do {
                            results = try self.managedContext.fetch(studentUniversityFetchRequest)
                            let nationalId = results.first!.nationalID
                            
                            if (nationalId != ""){
                                self.policyDetailsLines(actionId: "policies", nationalId: nationalId!)
                                return
                            } else {
                                LoadingIndicatorView.hideInMain()
                                return
                            }
                        } catch let error as NSError {
                            print ("Could not fetch \(error), \(error.userInfo)")
                        }
                    }
                    
                } else {
                    LoadingIndicatorView.hideInMain()
                    return
                }
            case .Error(let message):
                LoadingIndicatorView.hideInMain()
                self.alertDialog (heading: "", message: message);
            default:
                LoadingIndicatorView.hideInMain()
            }
        }
    }
    
    func policyDetailsLines(actionId: String, nationalId: String) -> Void {
        
        let endPoint: String = {
            return "\(constants.BASE_URL_LINES)?action_id=\(actionId)&national_id=\(nationalId)"
        }()
        
        self.webserviceManager.login(type: "double", endPoint: endPoint) { (result) in
            switch result {
            case .Success(let data, _):
                self.sharedInstance.clearPolicyDetailsLines()
                self.sharedInstance.saveInPolicyLinesDataWith(array: [data])
                self.accountSummaryLines(actionId: "vehicles", nationalId: nationalId)
            case .Error(let message):
                LoadingIndicatorView.hideInMain()
                self.alertDialog (heading: "", message: message);
            default:
                LoadingIndicatorView.hideInMain()
            }
        }
    }
    
    func accountSummaryLines(actionId: String, nationalId: String) -> Void {
        let endPoint: String = {
            return "\(constants.BASE_URL_LINES)?action_id=\(actionId)&national_id=\(nationalId)"
        }()
        
        self.webserviceManager.login(type: "double", endPoint: endPoint) { (result) in
            LoadingIndicatorView.hideInMain()
            switch result {
            case .Success(let data, _):
                self.sharedInstance.clearAccountSummaryLines()
                self.sharedInstance.saveInAccountSummaryLinesDataWith(array: [data])
                self.callHomeControllerLines()
            case .Error(let message):
                self.alertDialog (heading: "", message: message);
            default:
                self.alertDialog (heading: "", message: self.constants.errorMessage);
            }
        }
    }
    
    func policyDetails(actionId: String, nationalId: String) -> Void {
        //        LoadingIndicatorView.show("Fetching Data...")
        
        let endPoint: String = {
            return "\(constants.BASE_URL_SALARY)?action_id=\(actionId)&national_id=\(nationalId)"
        }()
        
        self.webserviceManager.login(type: "double", endPoint: endPoint) { (result) in
            switch result {
            case .Success(let data, _):
                self.sharedInstance.clearPolicyDetails()
                self.sharedInstance.saveInPolicyDataWith(array: [data])
                self.accountSummary(actionId: "vehicles", nationalId: nationalId)
            case .Error(let message):
                LoadingIndicatorView.hideInMain()
                self.alertDialog (heading: "", message: message);
            default:
                LoadingIndicatorView.hideInMain()
            }
        }
    }
    
    func accountSummary(actionId: String, nationalId: String) -> Void {
        let endPoint: String = {
            return "\(constants.BASE_URL_SALARY)?action_id=\(actionId)&national_id=\(nationalId)"
        }()
        
        self.webserviceManager.login(type: "double", endPoint: endPoint) { (result) in
            LoadingIndicatorView.hideInMain()
            switch result {
            case .Success(let data, _):
                self.sharedInstance.clearAccountSummary()
                self.sharedInstance.saveInAccountSummaryDataWith(array: [data])
                self.callHomeControllerSalary()
            case .Error(let message):
                self.alertDialog (heading: "", message: message);
            default:
                self.alertDialog (heading: "", message: self.constants.errorMessage);
            }
        }
    }
    
    func staffDetails(actionId: String, phoneNumber: String, staffID: String, clientID: String) -> Void {
//        LoadingIndicatorView.show("Fetching Data...")
        
        let endPoint: String = {
            return "\(constants.BASE_URL)?action_id=\(actionId)&mobile_no=\(phoneNumber)&staff_id=\(staffID)&client_no=\(clientID)"
        }()
        
        self.webserviceManager.login(type: "double", endPoint: endPoint) { (result) in
            switch result {
            case .Success(let data, let require_update):
                if (require_update == "yes") {
                    self.sharedInstance.clearStaffDetails()
                    self.sharedInstance.saveInStaffDataWith(array: [data])
                }
                self.claimDetails(actionId: "claim_status", staffID: staffID, clientID: clientID)
            case .Error(let message):
                LoadingIndicatorView.hideInMain()
                self.alertDialog (heading: "", message: message);
            default:
                LoadingIndicatorView.hideInMain()
            }
        }
    }
    
    func claimDetails(actionId: String, staffID: String, clientID: String) -> Void {
        
        let endPoint: String = {
            return "\(constants.BASE_URL)?action_id=\(actionId)&staff_id=\(staffID)&client_no=\(clientID)"
        }()
        
        self.webserviceManager.login(type: "double", endPoint: endPoint) { (result) in
            switch result {
            case .Success(let data, let require_update):
                if (require_update == "yes") {
                    self.sharedInstance.clearClaimDetails()
                    self.sharedInstance.saveInClaimDataWith(array: [data])
                }
                self.preApproval(actionId: "pre_approval", staffID: staffID, clientID: clientID)
            case .Error(let message):
                LoadingIndicatorView.hideInMain()
                self.alertDialog (heading: "", message: message);
            default:
                LoadingIndicatorView.hideInMain()
            }
        }
    }
    
    func preApproval(actionId: String, staffID: String, clientID: String) -> Void {
        
        let endPoint: String = {
            return "\(constants.BASE_URL)?action_id=\(actionId)&staff_id=\(staffID)&client_no=\(clientID)"
        }()
        
        self.webserviceManager.login(type: "double", endPoint: endPoint) { (result) in
            switch result {
            case .Success(let data, let require_update):
                if (require_update == "yes") {
                    self.sharedInstance.clearPreApprovalDetails()
                    self.sharedInstance.saveInPreApprovalDataWith(array: [data])
                }
                LoadingIndicatorView.hideInMain()
                self.callHomeController()
            case .Error(let message):
                LoadingIndicatorView.hideInMain()
                self.alertDialog (heading: "", message: message);
            default:
                LoadingIndicatorView.hideInMain()
            }
        }
    }
    
    func alertDialog (heading: String, message: String) {
        OperationQueue.main.addOperation {
            LoadingIndicatorView.hide()
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
        
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func callHomeController () {
        OperationQueue.main.addOperation {
            self.createMenuView()
        }
    }
    
    func callHomeControllerSalary () {
        OperationQueue.main.addOperation {
            self.createMenuViewSalary()
        }
    }
    
    func callHomeControllerLines () {
        OperationQueue.main.addOperation {
            self.createMenuViewLines()
        }
    }
    
    private func createMenuView() {
        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "HomeController") as! HomeController
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        leftViewController.isEb = true
        
        leftViewController.mainViewController = mainViewController
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.hideStatusBar = false;
        
        let slideMenuController = ExSlideMenuController(mainViewController:mainViewController, leftMenuViewController: leftViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = mainViewController
        
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = slideMenuController
        appDelegate?.window??.makeKeyAndVisible()
    }
    
    private func createMenuViewSalary() {
        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "HomeControllerSalary") as! HomeControllerSalary
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        
        leftViewController.mainViewController = mainViewController
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.hideStatusBar = false;
        
        let slideMenuController = ExSlideMenuController(mainViewController:mainViewController, leftMenuViewController: leftViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = mainViewController
        
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = slideMenuController
        appDelegate?.window??.makeKeyAndVisible()
    }
    
    private func createMenuViewLines() {
        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "HomeControllerLines") as! HomeControllerLines
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        
        leftViewController.mainViewController = mainViewController
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.hideStatusBar = false;
        
        let slideMenuController = ExSlideMenuController(mainViewController:mainViewController, leftMenuViewController: leftViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = mainViewController
        
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = slideMenuController
        appDelegate?.window??.makeKeyAndVisible()
    }
}
