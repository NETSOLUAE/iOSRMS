//
//  ContactInfo.swift
//  RMS
//
//  Created by Mac Mini on 7/10/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

class ContactInfo: UIViewController {

    let constants = Constants();
    let webserviceManager = WebserviceManager();
    var section = [SectionContact]()
    var sectionAr = [SectionContactAr]()
    var selectedIndex = -1
    var selectedIndexAr = -1
    var currentLoadingText: String?
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewAr: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        background.backgroundColor = UIColor(patternImage: UIImage(named: "background-1")!)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 220
        self.tableViewAr.rowHeight = UITableViewAutomaticDimension
        self.tableViewAr.estimatedRowHeight = 220
        self.showActivityIndicator(view: self.view, targetVC: self)
        self.contactInfo(actionId: "company_addresses")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            tableView.isHidden = false
            tableViewAr.isHidden = true
        case 1:
            tableView.isHidden = true
            tableViewAr.isHidden = false
        default:
            break; 
        }
    }
    
    func contactInfo(actionId: String) -> Void {
        
        let urlString = constants.BASE_URL + "?action_id=" + actionId;
        
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
                        
                        if (status == "success"){
                            let data = parsedData["data"] as! [[String:Any]]
                                for data in data {
                                    var address1 = [Address]()
                                    var address1Ar = [AddressAr]()
                                    let country = data["country"] as? String ?? ""
                                    var countryAr = ""
                                        
                                    if data["addresses"] != nil {
                                        let addresses = data["addresses"] as! [[String:Any]]
                                        for addresses in addresses {
                                            var completeAddress = ""
                                            let branch_name = addresses["branch_name"] as? String ?? ""
                                            let attention = addresses["attention"] as? String ?? ""
                                            let p_o_box = addresses["p_o_box"] as? String ?? ""
                                            let postal_code = addresses["postal_code"] as? String ?? ""
                                            let address = addresses["address"] as? String ?? ""
                                            let telephone = addresses["telephone"] as? String ?? ""
                                            let mobile = addresses["mobile"] as? String ?? ""
                                            let fax = addresses["fax"] as? String ?? ""
                                            let email = addresses["email"] as? String ?? ""
                                            let hot_line = addresses["hot_line"] as? String ?? ""
                                            let direct_line = addresses["direct_line"] as? String ?? ""
                                            
                                            if (p_o_box != "") {
                                                completeAddress = completeAddress + "PO. Box " + p_o_box + " ,\r\n"
                                            }
                                            if (attention != "") {
                                                completeAddress = completeAddress + attention + " ,\r\n"
                                            }
                                            if (address != "") {
                                                completeAddress = completeAddress + address + " ,\r\n"
                                            }
                                            if (postal_code != "") {
                                                completeAddress = completeAddress + "Postal Code: " + postal_code + " ,\r\n"
                                            }
                                            if (telephone != "") {
                                                completeAddress = completeAddress + "Tel: " + telephone + " ,\r\n"
                                            }
                                            if (mobile != "") {
                                                completeAddress = completeAddress + "Mobile: " + mobile + " ,\r\n"
                                            }
                                            if (fax != "") {
                                                completeAddress = completeAddress + "Fax: " + fax + " ,\r\n"
                                            }
                                            if (email != "") {
                                                completeAddress = completeAddress + "Email: " + email + " ,\r\n"
                                            }
                                            if (hot_line != "") {
                                                completeAddress = completeAddress + "Hot Line: " + hot_line + " ,\r\n"
                                            }
                                            if (direct_line != "") {
                                                completeAddress = completeAddress + "Direct Line: " + direct_line
                                            }
                                            
                                            let underlineAttriString = NSMutableAttributedString(string: completeAddress)
                                            print(underlineAttriString)
                                            
                                            address1.append(Address(branch_name: branch_name, address: underlineAttriString, telephone: telephone, mobile: mobile, email: email))
                                            
                                            countryAr = addresses["country_ar"] as? String ?? ""
                                            if (countryAr != "null") {
                                                var completeAddressAr = ""
                                                let branch_name_ar = addresses["branch_name_ar"] as? String ?? ""
                                                let attention_ar = addresses["attention_ar"] as? String ?? ""
                                                let p_o_box_ar = addresses["p_o_box_ar"] as? String ?? ""
                                                let postal_code_ar = addresses["postal_code_ar"] as? String ?? ""
                                                let address_ar = addresses["address_ar"] as? String ?? ""
                                                let telephone_ar = addresses["telephone_ar"] as? String ?? ""
                                                let mobile_ar = addresses["mobile_ar"] as? String ?? ""
                                                let fax_ar = addresses["fax_ar"] as? String ?? ""
                                                let email_ar = addresses["email_ar"] as? String ?? ""
                                                let hot_line_ar = addresses["hot_line_ar"] as? String ?? ""
                                                
                                                if (p_o_box_ar != "") {
                                                    completeAddressAr = completeAddressAr + "ص.ب. " + p_o_box_ar + " ,\r\n"
                                                }
                                                if (attention_ar != "") {
                                                    completeAddressAr = completeAddressAr + attention_ar + " ,\r\n"
                                                }
                                                if (address_ar != "") {
                                                    completeAddressAr = completeAddressAr + address_ar + " ,\r\n"
                                                }
                                                if (postal_code_ar != "") {
                                                    completeAddressAr = completeAddressAr + "الرمز البريدي " + postal_code_ar + " ,\r\n"
                                                }
                                                if (telephone_ar != "") {
                                                    completeAddressAr = completeAddressAr + telephone_ar + " ,\r\n"
                                                }
                                                if (mobile_ar != "") {
                                                    completeAddressAr = completeAddressAr + mobile_ar + " ,\r\n"
                                                }
                                                if (fax_ar != "") {
                                                    completeAddressAr = completeAddressAr + fax_ar + " ,\r\n"
                                                }
                                                if (email_ar != "") {
                                                    completeAddressAr = completeAddressAr + email_ar + " ,\r\n"
                                                }
                                                if (hot_line_ar != "") {
                                                    completeAddressAr = completeAddressAr + hot_line_ar + " ,\r\n"
                                                }
                                                
                                                let underlineAttriString = NSMutableAttributedString(string: completeAddressAr)
                                                print(underlineAttriString)
                                                
                                                address1Ar.append(AddressAr(branch_name_ar: branch_name_ar, address_ar: underlineAttriString, telephone_ar: telephone_ar, mobile_ar: mobile_ar, email_ar: email_ar))
                                            }
                                        }
                                        self.section.append(SectionContact(genre: country, movies: address1, expanded: false))
                                        if (countryAr != "null" && countryAr != "") {
                                            self.sectionAr.append(SectionContactAr(branchAr: countryAr, addressAr: address1Ar, expandedAr: false))
                                        }
                                    }
                            }
                        } else if (status == "fail") {
                            self.alertDialog (heading: "", message: self.constants.errorMessage);
                            return
                        } else {
                            self.alertDialog (heading: "", message: self.constants.errorMessage);
                            return
                        }
                        DispatchQueue.main.sync(execute: {
                            /* stop the activity indicator (you are now on the main queue again) */
                            self.tableView.reloadData()
                            self.tableViewAr.reloadData()
                            self.tableView.isHidden = false
                            self.tableViewAr.isHidden = true
                            self.hideActivityIndicator(view: self.view)
                        });
                    } catch {
                        DispatchQueue.main.sync(execute: {
                            /* stop the activity indicator (you are now on the main queue again) */
                            self.hideActivityIndicator(view: self.view)
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
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func alertDialog1 (heading: String, phone: String, email: String, mobile: String) {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "",
                                          message: "",
                                          preferredStyle: .alert)
            // Change font of the title and message
            let titleFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "AmericanTypewriter", size: 18)! ]
            let attributedTitle = NSMutableAttributedString(string: "Action", attributes: titleFont)
            alert.setValue(attributedTitle, forKey: "attributedTitle")
            if (phone != ""){
                var phone1 = phone.replacingOccurrences(of: " ", with: "")
                phone1 = phone1.digits
                let phone = phone.digits
                let url:NSURL = NSURL(string: "tel://" + phone1)!
                let action1 = UIAlertAction(title: "Call " + phone, style: .default, handler: { (action) -> Void in
                    
                    if (UIApplication.shared.canOpenURL(url as URL))
                    {
                        if let urlMobile = NSURL(string: "tel://" + phone1), UIApplication.shared.canOpenURL(urlMobile as URL) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(urlMobile as URL, options: [:], completionHandler: nil)
                            }
                            else {
                                UIApplication.shared.openURL(urlMobile as URL)
                            }
                        }
                    }
                })
                alert.addAction(action1)
            }
            if (mobile != ""){
                let mobile1 = mobile.replacingOccurrences(of: " ", with: "")
                let url:NSURL = NSURL(string: "tel://" + mobile1)!
                let action1 = UIAlertAction(title: "Call " + mobile1, style: .default, handler: { (action) -> Void in
                    
                    if (UIApplication.shared.canOpenURL(url as URL))
                    {
                        if let urlMobile = NSURL(string: "tel://" + mobile1), UIApplication.shared.canOpenURL(urlMobile as URL) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(urlMobile as URL, options: [:], completionHandler: nil)
                            }
                            else {
                                UIApplication.shared.openURL(urlMobile as URL)
                            }
                        }
                    }
                })
                alert.addAction(action1)
            }
            
            if (email != "") {
                let email1 = email.replacingOccurrences(of: " ", with: "")
                let url:NSURL = NSURL(string: "mailto://" + email1)!
                let action2 = UIAlertAction(title: "Email " + email, style: .default, handler: { (action) -> Void in
                    if (UIApplication.shared.canOpenURL(url as URL))
                    {
                        if let urlMobile = NSURL(string: "mailto://" + email1), UIApplication.shared.canOpenURL(urlMobile as URL) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(urlMobile as URL, options: [:], completionHandler: nil)
                            }
                            else {
                                UIApplication.shared.openURL(urlMobile as URL)
                            }
                        }
//                        let options = [UIApplicationOpenURLOptionUniversalLinksOnly : true]
//                        UIApplication.shared.open(url as URL, options: options, completionHandler: nil)
                    }
                })
                alert.addAction(action2)
            }
            
            // Cancel button
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
            
            // Restyle the view of the Alert
            //            alert.view.tintColor = UIColor.brown  // change text color of the buttons
            //            alert.view.backgroundColor = UIColor.cyan  // change background color
            alert.view.layer.cornerRadius = 25   // change corner radius
            // Add action buttons and present the Alert
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showActivityIndicator(view: UIView, targetVC: UIViewController) {
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: targetVC.view.frame.width/2 - 25, y: targetVC.view.frame.height/2 - 150, width: 50, height: 50))
        activityIndicator.backgroundColor = UIColor.gray
        activityIndicator.layer.cornerRadius = 6
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        activityIndicator.tag = 1
        targetVC.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideActivityIndicator(view: UIView) {
        let activityIndicator = view.viewWithTag(1) as? UIActivityIndicatorView
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}

extension ContactInfo: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            let telephone = self.section[indexPath.section].movies[indexPath.row].telephone
            let email = self.section[indexPath.section].movies[indexPath.row].email
            let mobile = self.section[indexPath.section].movies[indexPath.row].mobile
            if (telephone != "" || email != "" || mobile != ""){
                self.alertDialog1(heading: "Choose Action", phone: telephone!, email: email!, mobile: mobile!)
            }
        } else if tableView == self.tableViewAr {
            let telephoneAr = self.sectionAr[indexPath.section].addressAr[indexPath.row].telephone_ar
            let emailAr = self.sectionAr[indexPath.section].addressAr[indexPath.row].email_ar
            let mobileAr = self.section[indexPath.section].movies[indexPath.row].mobile
            if (telephoneAr != "" || emailAr != "" || mobileAr != ""){
                self.alertDialog1(heading: "Choose Action", phone: telephoneAr!, email: emailAr!, mobile: mobileAr!)
            }
        }
    }
    
}

extension ContactInfo: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return section.count
        } else if tableView == self.tableViewAr {
            let count = sectionAr.count
            return count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section1: Int) -> Int {
        if tableView == self.tableView {
            return section[section1].movies.count
        } else if tableView == self.tableViewAr {
            return sectionAr[section1].addressAr.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            if (section[indexPath.section].expanded && selectedIndex == indexPath.section) {
                return UITableViewAutomaticDimension
            } else {
                return 0
            }
        } else if tableView == self.tableViewAr {
            if (sectionAr[indexPath.section].expandedAr! && selectedIndexAr == indexPath.section) {
                return UITableViewAutomaticDimension
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section1: Int) -> UIView? {
        if tableView == self.tableView {
            let header = ExpandableHeaderView()
            header.customInit(title: section[section1].genre, section: section1, delegate: self)
            return header
        } else if tableView == self.tableViewAr {
            let header = ExpandableHeaderViewAr()
            header.customInit(titleAr: sectionAr[section1].branchAr, sectionAr: section1, delegateAr: self)
            return header
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! Contact
            var branchName = self.section[indexPath.section].movies[indexPath.row].branch_name
            branchName = branchName?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            let address = self.section[indexPath.section].movies[indexPath.row].address
            print(address ?? "")
            cell.address.preferredMaxLayoutWidth = 404
            cell.branch.text = branchName
            cell.address.attributedText = address
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCellAr", for: indexPath) as! ContactAr
            var branchName = self.sectionAr[indexPath.section].addressAr[indexPath.row].branch_name_ar
            branchName = branchName?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            let address = self.sectionAr[indexPath.section].addressAr[indexPath.row].address_ar
            print(address ?? "")
            cell.address.preferredMaxLayoutWidth = 404
            cell.branch.text = branchName
            cell.address.attributedText = address
            
            return cell
        }
    }
    
}

extension ContactInfo: ExpandableHeaderViewDelegate {
    
    func toggleSection(header: ExpandableHeaderView, section section1: Int) {
        if (!section[section1].expanded && selectedIndex != section1) {
            section[section1].expanded = !section[section1].expanded
        } else if (section[section1].expanded && selectedIndex == section1) {
            section[section1].expanded = !section[section1].expanded
        } else if (!section[section1].expanded && selectedIndex == section1) {
            section[section1].expanded = !section[section1].expanded
        }
        selectedIndex = section1
        
        
        tableView.beginUpdates()
        for i in 0 ..< section[section1].movies.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section1)], with: .automatic)
        }
        tableView.endUpdates()
    }
}

extension ContactInfo: ExpandableHeaderViewDelegateAr {
    
    func toggleSectionAr(header: ExpandableHeaderViewAr, section section1: Int) {
        if (!sectionAr[section1].expandedAr && selectedIndexAr != section1) {
            sectionAr[section1].expandedAr = !sectionAr[section1].expandedAr
        } else if (sectionAr[section1].expandedAr && selectedIndexAr == section1) {
            sectionAr[section1].expandedAr = !sectionAr[section1].expandedAr
        } else if (!sectionAr[section1].expandedAr && selectedIndexAr == section1) {
            sectionAr[section1].expandedAr = !sectionAr[section1].expandedAr
        }
        selectedIndexAr = section1
        
        
        tableViewAr.beginUpdates()
        for i in 0 ..< sectionAr[section1].addressAr.count {
            tableViewAr.reloadRows(at: [IndexPath(row: i, section: section1)], with: .automatic)
        }
        tableViewAr.endUpdates()
    }
}

extension String {
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

