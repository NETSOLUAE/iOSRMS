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
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var loginAction: UIButton!
    @IBOutlet weak var pin1: UITextField!
    @IBOutlet weak var pin3: UITextField!
    @IBOutlet weak var pin2: UITextField!
    @IBOutlet weak var pin4: UITextField!
    
    @IBOutlet weak var forget: UILabel!
    let constants = Constants();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pin1.delegate = self;
        pin2.delegate = self;
        pin3.delegate = self;
        pin4.delegate = self;
        
        pin1.textAlignment = NSTextAlignment.center;
        pin2.textAlignment = NSTextAlignment.center;
        pin3.textAlignment = NSTextAlignment.center;
        pin4.textAlignment = NSTextAlignment.center;
        
        pin1.isSecureTextEntry = true
        pin2.isSecureTextEntry = true
        pin3.isSecureTextEntry = true
        pin4.isSecureTextEntry = true
        
        pin1.becomeFirstResponder();
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        forget.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func tapFunction(sender:UITapGestureRecognizer) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "MASTER_DATA")
        do {
            let people = try managedContext.fetch(fetchRequest)
            for people in people {
                let mobileNumber = (people.value(forKey: "mobileNumber") ?? "") as! String;
                let staffId = (people.value(forKey: "staffID") ?? "") as! String;
                let clientId = (people.value(forKey: "clientID") ?? "") as! String;
                self.sendSms(actionId: "send_sms", phoneNumber: mobileNumber, staffID: staffId, clientID: clientId)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pin1.becomeFirstResponder();
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "MASTER_DATA")
        do {
            let people = try managedContext.fetch(fetchRequest)
            for people in people {
                let mobileNumber = (people.value(forKey: "mobileNumber") ?? "") as! String;
                if (mobileNumber != ""){
                    self.phoneNumber.text = mobileNumber;
                    self.phoneNumber.isUserInteractionEnabled = false;
                    return
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        let phoneText: NSString = self.phoneNumber.text! as NSString;
        let pin1Text: NSString = self.pin1.text! as NSString;
        let pin2Text: NSString = self.pin2.text! as NSString;
        let pin3Text: NSString = self.pin3.text! as NSString;
        let pin4Text: NSString = self.pin4.text! as NSString;
        
        if (phoneText != ""){
            if (pin1Text != "" && pin2Text != "" && pin3Text != "" && pin4Text != "") {
                let pin = self.pin1.text! + self.pin2.text! + self.pin3.text! + self.pin4.text!;
                /* start the activity indicator (you are now on the main queue) */
                
                DispatchQueue.main.async(execute: {
                    /* Do some heavy work (you are now on a background queue) */
                    LoadingIndicatorView.show("Authenticating...")
                    });
                self.pin1.resignFirstResponder()
                self.pin2.resignFirstResponder()
                self.pin3.resignFirstResponder()
                self.pin4.resignFirstResponder()
                loginCall(actionId: "login", phoneNumber: phoneText as String, pin: pin, deviceID: constants.deviceID , staffID: "" , clientID: "")
            } else {
                alertDialog (heading: "Alert", message: "Please Enter Valid PIN");
            }
        } else {
            alertDialog (heading: "Alert", message: "Please Enter your Phone Number");
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
    
    func textField(_ pin1: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 1
        let currentString: NSString = pin1.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textField2(_ pin2: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 1
        let currentString: NSString = pin2.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textField3(_ pin3: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 1
        let currentString: NSString = pin3.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textField4(_ pin4: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 1
        let currentString: NSString = pin4.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
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
    
    func sendSms(actionId: String, phoneNumber: String, staffID: String, clientID: String) -> Void {
        
        DispatchQueue.main.async(execute: {
            /* Do some heavy work (you are now on a background queue) */
            LoadingIndicatorView.show("Sending SMS....")
        });
        let POST_PARAMS = "?action_id=" + actionId + "&mobile_no="  + phoneNumber + "&staff_id=" + staffID + "&client_no=" + clientID;
        
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
                            DispatchQueue.main.sync(execute: {
                                /* stop the activity indicator (you are now on the main queue again) */
                                LoadingIndicatorView.hide()
                            });
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
    
    func loginCall(actionId: String, phoneNumber: String, pin: String, deviceID: String, staffID: String, clientID: String) -> Void {
        var POST_PARAMS = "";
        if (staffID == "" && clientID == "" && actionId == "login") {
            POST_PARAMS = "?action_id=" + actionId + "&mobile_no=" + phoneNumber + "&pin_code=" + pin + "&device_id=" + deviceID;
        } else if (actionId == "login"){
            POST_PARAMS = "?action_id=" + actionId + "&mobile_no="  + phoneNumber + "&pin_code=" + pin + "&device_id=" + deviceID + "&staff_id=" + staffID + "&client_no=" + clientID;
        } else {
            POST_PARAMS = "?action_id=" + actionId + "&mobile_no="  + phoneNumber + "&new_pin_code=" + pin + "&device_id=" + deviceID + "&staff_id=" + staffID + "&client_no=" + clientID;
        }
        
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
                            self.deleteMaster()
                            let data = parsedData["data"] as! [String:Any]
                            for (_, _) in data {
                                let staffID = data["staff_id"] as? String ?? ""
                                let clientID = data["client_no"] as? String ?? ""
                                let change_pin = data["change_pin"] as? String ?? ""
                                self.save(phoneNumber: phoneNumber, changePin: change_pin, staffID: staffID, clientID: clientID, pinText: pin)
                                if (actionId == "login") {
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
                                            if (mobileNumber != "" && staffID != ""  && clientID != "" ){
                                                self.staffDetails(actionId: "staff_details", phoneNumber: mobileNumber, staffID: staffID, clientID: clientID)
                                                return
                                            } else {
                                                DispatchQueue.main.sync(execute: {
                                                    /* stop the activity indicator (you are now on the main queue again) */
                                                    LoadingIndicatorView.hide()
                                                });
                                                return
                                            }
                                        }
                                    } catch let error as NSError {
                                        print("Could not fetch. \(error), \(error.userInfo)")
                                    }
                                } else {
                                    DispatchQueue.main.sync(execute: {
                                        /* stop the activity indicator (you are now on the main queue again) */
                                        LoadingIndicatorView.hide()
                                    });
                                    return
                                }
                            }
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
    
    func save(phoneNumber: String, changePin: String, staffID: String, clientID: String, pinText: String) {
        
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
        data.setValue(pinText, forKeyPath: "pin")
        data.setValue(phoneNumber, forKeyPath: "mobileNumber")
        data.setValue(changePin, forKeyPath: "changePin")
        data.setValue(staffID, forKeyPath: "staffID")
        data.setValue(clientID, forKeyPath: "clientID")
        let moc = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = moc
        
        privateMOC.perform({
            do {
                try privateMOC.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        })
    }
    
    func deleteMaster () {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<MASTER_DATA> = MASTER_DATA.fetchRequest()
        
        do {
            //go get the results
            let array_users = try context.fetch(fetchRequest)
            
            //You need to convert to NSManagedObject to use 'for' loops
            for user in array_users as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                context.delete(user)
            }
            //save the context
            
            do {
                try context.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func staffDetails(actionId: String, phoneNumber: String, staffID: String, clientID: String) -> Void {
//        LoadingIndicatorView.show("Fetching Data...")
        let POST_PARAMS = "?action_id=" + actionId + "&mobile_no="  + phoneNumber + "&staff_id=" + staffID + "&client_no=" + clientID;
        
        let urlString = constants.BASE_URL + POST_PARAMS;
        
        // Create request with URL
        let url = URL(string: urlString)!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"
        
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
                        let require_update = parsedData["require_update"] as! String
                        
                        if (status == "success"){
                            self.deleteStaff()
                            if (require_update == "yes") {
                                let data = parsedData["data"] as! [[String:Any]]
                                for data in data {
                                    for (_, _) in data {
                                        let clientID = data["client_id"] as? String ?? ""
                                        let staffID = data["staff_id"] as? String ?? ""
                                        let policy_ref = data["policy_ref"] as? String ?? ""
                                        let member_id = data["member_id"] as? String ?? ""
                                        let member_name = data["member_name"] as? String ?? ""
                                        let relationship = data["relationship"] as? String ?? ""
                                        let dender1 = data["dender"] as? String ?? ""
                                        let nationality1 = data["nationality"] as? String ?? ""
                                        let phone1 = data["phone"] as? String ?? ""
                                        let effective_date1 = data["effective_date"] as? String ?? ""
                                        let email1 = data["email"] as? String ?? ""
                                        self.saveStaffDetails(clientID: clientID, staffID: staffID, policy_ref: policy_ref, member_id: member_id, member_name: member_name,
                                                              relationship: relationship, dender: dender1, nationality: nationality1, phone: phone1, effective_date: effective_date1, email: email1)
                                        
                                        if data["dependents"] != nil {
                                            self.deleteDependent()
                                            let dependent = data["dependents"] as! [[String:Any]]
                                            for dependent in dependent {
                                                let clientID = dependent["client_id"] as? String ?? ""
                                                let staffID = dependent["staff_id"] as? String ?? ""
                                                let policy_ref = dependent["policy_ref"] as? String ?? ""
                                                let member_id = dependent["member_id"] as? String ?? ""
                                                let member_name = dependent["member_name"] as? String ?? ""
                                                let relationship = dependent["relationship"] as? String ?? ""
                                                let dender = dependent["dender"] as? String ?? ""
                                                let nationality = dependent["nationality"] as? String ?? ""
                                                let phone = dependent["phone"] as? String ?? ""
                                                let effective_date = dependent["effective_date"] as? String ?? ""
                                                let email = dependent["email"] as? String ?? ""
                                                self.saveDependentDetails(clientID: clientID, staffID: staffID, policy_ref: policy_ref, member_id: member_id, member_name: member_name,
                                                                          relationship: relationship, dender: dender, nationality: nationality, phone: phone, effective_date: effective_date, email: email)
                                                
                                            }
                                            
                                        }
                                        
                                        if data["pdfs"] != nil {
                                            self.deletePdf()
                                            let pdfs = data["pdfs"] as! [String:Any]
                                            for (key, _) in pdfs {
                                                var pdf_name = "";
                                                var pdf_link = "";
                                                if (key == "member_guide"){
                                                    pdf_link = pdfs["member_guide"] as? String ?? ""
                                                    pdf_name = "Member Guide";
                                                }else if (key == "hospital_network"){
                                                    pdf_link = pdfs["hospital_network"] as? String ?? ""
                                                    pdf_name = "Hospital Network";
                                                }else if (key == "claim_form"){
                                                    pdf_link = pdfs["claim_form"] as? String ?? ""
                                                    pdf_name = "Claim Form";
                                                }else if (key == "pre_approval_form"){
                                                    pdf_link = pdfs["pre_approval_form"] as? String ?? ""
                                                    pdf_name = "Pre Approval Form";
                                                }
                                                self.savePdfDetails(pdfName: pdf_name, pdfLink: pdf_link)
                                            }
                                            self.claimDetails(actionId: "claim_status", staffID: staffID, clientID: clientID)
                                            return
                                        }
                                    }
                                }
                            } else {
                                self.claimDetails(actionId: "claim_status", staffID: staffID, clientID: clientID)
                                return
                            }
                        } else if (status == "fail") {
                            DispatchQueue.main.sync(execute: {
                                /* stop the activity indicator (you are now on the main queue again) */
                                LoadingIndicatorView.hide()
                            });
                            self.alertDialog (heading: "", message: self.constants.errorMessage);
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
    
    func savePdfDetails(pdfName: String, pdfLink: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let master_data =
            NSEntityDescription.entity(forEntityName: "PDF",
                                       in: managedContext)!
        
        let data = NSManagedObject(entity: master_data,
                                   insertInto: managedContext)
        data.setValue(pdfName, forKeyPath: "pdf_name")
        data.setValue(pdfLink, forKeyPath: "pdf_link")
        let moc = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = moc
        
        privateMOC.perform({
            do {
                try privateMOC.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        })
    }
    
    func saveDependentDetails(clientID: String, staffID: String, policy_ref: String, member_id: String, member_name: String, relationship: String, dender: String, nationality: String,
                              phone: String, effective_date: String, email: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let master_data =
            NSEntityDescription.entity(forEntityName: "DEPENDENT_DETAILS",
                                       in: managedContext)!
        
        let data = NSManagedObject(entity: master_data,
                                   insertInto: managedContext)
        data.setValue(clientID, forKeyPath: "client_id")
        data.setValue(staffID, forKeyPath: "staff_id")
        data.setValue(policy_ref, forKeyPath: "policy_ref")
        data.setValue(member_id, forKeyPath: "member_id")
        data.setValue(member_name, forKeyPath: "member_name")
        if (relationship == "S"){
            data.setValue("Son", forKeyPath: "relationship")
        }else if (relationship == "W"){
            data.setValue("Wife", forKeyPath: "relationship")
        }else if (relationship == "H"){
            data.setValue("Husband", forKeyPath: "relationship")
        }else if (relationship == "D"){
            data.setValue("Daughter", forKeyPath: "relationship")
        }else {
            data.setValue(relationship, forKeyPath: "relationship")
        }
        data.setValue(dender, forKeyPath: "dender")
        data.setValue(nationality, forKeyPath: "nationality")
        data.setValue(phone, forKeyPath: "phone")
        data.setValue(effective_date, forKeyPath: "effective_date")
        data.setValue(email, forKeyPath: "email")
        let moc = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = moc
        
        privateMOC.perform({
            do {
                try privateMOC.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        })
    }
    
    func saveStaffDetails(clientID: String, staffID: String, policy_ref: String, member_id: String, member_name: String, relationship: String, dender: String, nationality: String,
                          phone: String, effective_date: String, email: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let master_data =
            NSEntityDescription.entity(forEntityName: "STAFF_DETAILS",
                                       in: managedContext)!
        
        let data = NSManagedObject(entity: master_data,
                                   insertInto: managedContext)
        data.setValue(clientID, forKeyPath: "client_id")
        data.setValue(staffID, forKeyPath: "staff_id")
        data.setValue(policy_ref, forKeyPath: "policy_ref")
        data.setValue(member_id, forKeyPath: "member_id")
        data.setValue(member_name, forKeyPath: "member_name")
        data.setValue(relationship, forKeyPath: "relationship")
        data.setValue(dender, forKeyPath: "dender")
        data.setValue(nationality, forKeyPath: "nationality")
        data.setValue(phone, forKeyPath: "phone")
        data.setValue(effective_date, forKeyPath: "effective_date")
        data.setValue(email, forKeyPath: "email")
        let moc = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = moc
        
        privateMOC.perform({
            do {
                try privateMOC.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        })
    }
    
    func deleteStaff () {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<STAFF_DETAILS> = STAFF_DETAILS.fetchRequest()
        
        do {
            //go get the results
            let array_users = try context.fetch(fetchRequest)
            
            //You need to convert to NSManagedObject to use 'for' loops
            for user in array_users as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                context.delete(user)
            }
            //save the context
            
            do {
                try context.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func deleteDependent () {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<DEPENDENT_DETAILS> = DEPENDENT_DETAILS.fetchRequest()
        
        do {
            //go get the results
            let array_users = try context.fetch(fetchRequest)
            
            //You need to convert to NSManagedObject to use 'for' loops
            for user in array_users as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                context.delete(user)
            }
            //save the context
            
            do {
                try context.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func deletePdf () {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<PDF> = PDF.fetchRequest()
        
        do {
            //go get the results
            let array_users = try context.fetch(fetchRequest)
            
            //You need to convert to NSManagedObject to use 'for' loops
            for user in array_users as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                context.delete(user)
            }
            //save the context
            
            do {
                try context.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func claimDetails(actionId: String, staffID: String, clientID: String) -> Void {
        let POST_PARAMS = "?action_id=" + actionId + "&staff_id=" + staffID + "&client_no=" + clientID;
        
        let urlString = constants.BASE_URL + POST_PARAMS;
        
        // Create request with URL
        let url = URL(string: urlString)!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"
        
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
                        let require_update = parsedData["require_update"] as! String
                        
                        if (status == "success"){
                            if (require_update == "yes") {
                                self.deleteUser ()
                                let data = parsedData["data"] as! [[String:Any]]
                                for data in data {
                                        let claim_no = data["claim_no"] as? String ?? ""
                                        let reg_date = data["reg_date"] as? String ?? ""
                                        let member_name = data["member_name"] as? String ?? ""
                                        let staff_name = data["staff_name"] as? String ?? ""
                                        let treatment_date = data["treatment_date"] as? String ?? ""
                                        let status = data["status"] as? String ?? ""
                                        let member_type = data["member_type"] as? String ?? ""
                                        let claimed_mount = data["amount"] as? String ?? ""
                                        let approved_amount = data["payment"] as? String ?? ""
                                        let excess = data["excess"] as? String ?? ""
                                        let disallowance = data["disallowance"] as? String ?? ""
                                        let settled_amount_ro = data["ref_amnt"] as? String ?? ""
                                        let mode_of_payment = data["mode_of_payment"] as? String ?? ""
                                        let cheque_no = data["cheque_no"] as? String ?? ""
                                        let settled_amount = data["cheque_rec_date"] as? String ?? ""
                                        let remarks = data["remarks"] as? String ?? ""
                                        let policy_no = data["policy_no"] as? String ?? ""
                                        let diagnosis = data["diagnosis"] as? String ?? ""
                                        self.saveClaimDetails(claim_no: claim_no, reg_date: reg_date, member_name: member_name, staff_name: staff_name, treatment_date: treatment_date,
                                                              status: status, member_type: member_type, claimed_mount: claimed_mount, approved_amount: approved_amount, excess: excess, disallowance: disallowance, settled_amount_ro: settled_amount_ro, mode_of_payment: mode_of_payment, cheque_no: cheque_no, settled_amount: settled_amount, remarks: remarks, policy_no: policy_no, diagnosis: diagnosis)
                                }
                                self.preApproval(actionId: "pre_approval", staffID: staffID, clientID: clientID)
                                return
                            } else {
                                //Delete Core Data Details
                                self.preApproval(actionId: "pre_approval", staffID: staffID, clientID: clientID)
                                return
                            }
                        } else if (status == "fail") {
                            DispatchQueue.main.sync(execute: {
                                /* stop the activity indicator (you are now on the main queue again) */
                                LoadingIndicatorView.hide()
                            });
                            self.alertDialog (heading: "", message: self.constants.errorMessage);
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
    
    func saveClaimDetails(claim_no: String, reg_date: String, member_name: String, staff_name: String, treatment_date: String, status: String, member_type: String, claimed_mount: String,
                          approved_amount: String, excess: String, disallowance: String, settled_amount_ro: String, mode_of_payment: String, cheque_no: String, settled_amount: String, remarks: String, policy_no: String, diagnosis: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let master_data =
            NSEntityDescription.entity(forEntityName: "CLAIM_DETAILS",
                                       in: managedContext)!
        
        let data = NSManagedObject(entity: master_data,
                                   insertInto: managedContext)
        data.setValue(claim_no, forKeyPath: "claim_no")
        data.setValue(reg_date, forKeyPath: "reg_date")
        data.setValue(member_name, forKeyPath: "member_name")
        data.setValue(staff_name, forKeyPath: "staff_name")
        data.setValue(treatment_date, forKeyPath: "treatment_date")
        data.setValue(status, forKeyPath: "status")
        data.setValue(member_type, forKeyPath: "member_type")
        data.setValue(claimed_mount, forKeyPath: "claimed_mount")
        data.setValue(approved_amount, forKeyPath: "approved_amount")
        data.setValue(excess, forKeyPath: "excess")
        data.setValue(disallowance, forKeyPath: "disallowance")
        data.setValue(settled_amount_ro, forKeyPath: "settled_amount_ro")
        data.setValue(mode_of_payment, forKeyPath: "mode_of_payment")
        data.setValue(cheque_no, forKeyPath: "cheque_no")
        data.setValue(settled_amount, forKeyPath: "settled_amount")
        data.setValue(remarks, forKeyPath: "remarks")
        data.setValue(policy_no, forKeyPath: "policy_no")
        data.setValue(diagnosis, forKeyPath: "diagnosis")
        let moc = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = moc
        
        privateMOC.perform({
            do {
                try privateMOC.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        })
    }
    
    func deleteUser () {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<CLAIM_DETAILS> = CLAIM_DETAILS.fetchRequest()
        
        do {
            //go get the results
            let array_users = try context.fetch(fetchRequest)
            
            //You need to convert to NSManagedObject to use 'for' loops
            for user in array_users as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                context.delete(user)
            }
            //save the context
            
            do {
                try context.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func preApproval(actionId: String, staffID: String, clientID: String) -> Void {
        let POST_PARAMS = "?action_id=" + actionId + "&staff_id=" + staffID + "&client_no=" + clientID;
        
        let urlString = constants.BASE_URL + POST_PARAMS;
        
        // Create request with URL
        let url = URL(string: urlString)!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"
        
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
                        let require_update = parsedData["require_update"] as! String
                        
                        if (status == "success"){
                            if (require_update == "yes") {
                                self.deletePre()
                                let data = parsedData["data"] as! [[String:Any]]
                                for data in data {
                                        let memberid = data["memberid"] as? String ?? ""
                                        let patient_name = data["patient_name"] as? String ?? ""
                                        let staff_id = data["staff_id"] as? String ?? ""
                                        let staff_name = data["staff_name"] as? String ?? ""
                                        let pol_ref = data["pol_ref"] as? String ?? ""
                                        let entry_dt = data["entry_dt"] as? String ?? ""
                                        let diagnosis = data["diagnosis"] as? String ?? ""
                                        let place_code = data["place_code"] as? String ?? ""
                                        let hospital_name = data["hospital_name"] as? String ?? ""
                                        let pre_approvalno = data["pre_approvalno"] as? String ?? ""
                                        let pre_approvaldt = data["pre_approvaldt"] as? String ?? ""
                                        let remarks = data["remarks"] as? String ?? ""
                                        let status = data["status"] as? String ?? ""
                                        self.savepreApproval(memberid: memberid, patient_name: patient_name, staff_id: staff_id, staff_name: staff_name, pol_ref: pol_ref,
                                                              entry_dt: entry_dt, diagnosis: diagnosis, place_code: place_code, hospital_name: hospital_name, pre_approvalno: pre_approvalno, pre_approvaldt: pre_approvaldt, remarks: remarks, status: status)
                                    
                                }
                                DispatchQueue.main.sync(execute: {
                                    /* stop the activity indicator (you are now on the main queue again) */
                                    LoadingIndicatorView.hide()
                                });
                                self.callHomeController()
                                return
                            } else {
                                //Delete Core Data Details
                                DispatchQueue.main.sync(execute: {
                                    /* stop the activity indicator (you are now on the main queue again) */
                                    LoadingIndicatorView.hide()
                                });
                                return
                            }
                        } else if (status == "fail") {
                            DispatchQueue.main.sync(execute: {
                                /* stop the activity indicator (you are now on the main queue again) */
                                LoadingIndicatorView.hide()
                            });
                            self.alertDialog (heading: "", message: self.constants.errorMessage);
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
    
    func savepreApproval(memberid: String, patient_name: String, staff_id: String, staff_name: String, pol_ref: String, entry_dt: String, diagnosis: String, place_code: String,
                          hospital_name: String, pre_approvalno: String, pre_approvaldt: String, remarks: String, status: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let master_data =
            NSEntityDescription.entity(forEntityName: "PRE_APPROVALS",
                                       in: managedContext)!
        
        let data = NSManagedObject(entity: master_data,
                                   insertInto: managedContext)
        data.setValue(memberid, forKeyPath: "memberid")
        data.setValue(patient_name, forKeyPath: "patient_name")
        data.setValue(staff_id, forKeyPath: "staff_id")
        data.setValue(staff_name, forKeyPath: "staff_name")
        data.setValue(pol_ref, forKeyPath: "pol_ref")
        data.setValue(entry_dt, forKeyPath: "entry_dt")
        data.setValue(diagnosis, forKeyPath: "diagnosis")
        data.setValue(place_code, forKeyPath: "place_code")
        data.setValue(hospital_name, forKeyPath: "hospital_name")
        data.setValue(pre_approvalno, forKeyPath: "pre_approvalno")
        data.setValue(pre_approvaldt, forKeyPath: "pre_approvaldt")
        data.setValue(remarks, forKeyPath: "remarks")
        data.setValue(status, forKeyPath: "status")
        let moc = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = moc
        
        privateMOC.perform({
            do {
                try privateMOC.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        })
    }
    
    func deletePre () {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<PRE_APPROVALS> = PRE_APPROVALS.fetchRequest()
        
        do {
            //go get the results
            let array_users = try context.fetch(fetchRequest)
            
            //You need to convert to NSManagedObject to use 'for' loops
            for user in array_users as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                context.delete(user)
            }
            //save the context
            
            do {
                try context.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
            
        } catch {
            print("Error with request: \(error)")
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
    
    private func createMenuView() {
        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "HomeController") as! HomeController
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
