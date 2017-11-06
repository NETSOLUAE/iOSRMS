//
//  MemberDetails.swift
//  RMS
//
//  Created by Mac Mini on 7/1/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import CoreData

//
// MARK: - Section Data Structure
//
struct Section {
    var name: String!
    var gender: String!
    var items: [String]!
    var relationship: [String]!
    var genderArray: [String]!
    var policyNo: [String]!
    var nationality: [String]!
    var mobile: [String]!
    var email: [String]!
    var collapsed: Bool!
    
    init(name: String, gender: String, items: [String], relationship: [String], genderArray: [String], policyNo: [String], nationality: [String], mobile: [String], email: [String], collapsed: Bool = false) {
        self.name = name
        self.gender = gender
        self.items = items
        self.relationship = relationship
        self.relationship = relationship
        self.genderArray = genderArray
        self.policyNo = policyNo
        self.nationality = nationality
        self.mobile = mobile
        self.email = email
        self.collapsed = collapsed
    }
}

class MemberDetails: UITableViewController, IndicatorInfoProvider {
    var itemInfo: IndicatorInfo = "Member Details"
    var sections = [Section]()
    let refreshControl1 = UIRefreshControl()
    let sharedInstance = CoreDataManager.sharedInstance;
    let constants = Constants()
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
        let nib = UINib(nibName: "MemberGroup", bundle: Bundle.main)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "MemberGroup")
        tableView.register(UINib(nibName: "MemberChild", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        tableView.tableFooterView = UIView (frame: CGRect.zero)
        
        // Add to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl1
        } else {
            tableView.addSubview(refreshControl1)
        }
        refreshControl1.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl1.attributedTitle = NSAttributedString(string: "Refershing Member Details ...")
        // Configure Refresh Control
        self.refreshControl1.addTarget(self, action: #selector(self.refreshMemberDetails(refreshControl:)), for: .valueChanged)
        
        var dependentsArray = Array<String>()
        var relationArray = Array<String>()
        var genderArray = Array<String>()
        var policyNoArray = Array<String>()
        var nationalityArray = Array<String>()
        var mobileArray = Array<String>()
        var emailArray = Array<String>()
        
        // Initialize the sections array
        let managedContext =
            sharedInstance.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS")
        do {
            let people = try managedContext.fetch(fetchRequest)
            for people in people {
                let memberName = (people.value(forKey: "member_name") ?? "") as! String;
                let gender = (people.value(forKey: "dender") ?? "") as! String;
                var dependents  = [DEPENDENT_DETAILS]() // Where Locations = your NSManaged Class
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DEPENDENT_DETAILS")
                do {
                    dependents = try managedContext.fetch(fetchRequest) as! [DEPENDENT_DETAILS]
                    for dependents in dependents {
                        dependentsArray.append(dependents.member_name!)
                        relationArray.append(dependents.relationship!)
                        genderArray.append(dependents.dender!)
                        policyNoArray.append(dependents.policy_ref!)
                        nationalityArray.append(dependents.nationality!)
                        mobileArray.append(dependents.phone!)
                        emailArray.append(dependents.email!)
                    }
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                sections.append(Section(name: memberName, gender: gender, items: dependentsArray, relationship: relationArray, genderArray: genderArray, policyNo: policyNoArray, nationality: nationalityArray, mobile: mobileArray, email: emailArray))
                return
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    func refreshMemberDetails(refreshControl: UIRefreshControl) {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
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
                    
                    var dependentsArray = Array<String>()
                    var relationArray = Array<String>()
                    var genderArray = Array<String>()
                    var policyNoArray = Array<String>()
                    var nationalityArray = Array<String>()
                    var mobileArray = Array<String>()
                    var emailArray = Array<String>()
                    
                    // Initialize the sections array
                    let managedContext =
                        self.sharedInstance.persistentContainer.viewContext
                    
                    let fetchRequest =
                        NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS")
                    do {
                        let people = try managedContext.fetch(fetchRequest)
                        for people in people {
                            let memberName = (people.value(forKey: "member_name") ?? "") as! String;
                            let gender = (people.value(forKey: "dender") ?? "") as! String;
                            var dependents  = [DEPENDENT_DETAILS]() // Where Locations = your NSManaged Class
                            
                            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DEPENDENT_DETAILS")
                            do {
                                dependents = try managedContext.fetch(fetchRequest) as! [DEPENDENT_DETAILS]
                                for dependents in dependents {
                                    dependentsArray.append(dependents.member_name!)
                                    relationArray.append(dependents.relationship!)
                                    genderArray.append(dependents.dender!)
                                    policyNoArray.append(dependents.policy_ref!)
                                    nationalityArray.append(dependents.nationality!)
                                    mobileArray.append(dependents.phone!)
                                    emailArray.append(dependents.email!)
                                }
                            } catch let error as NSError {
                                print("Could not fetch. \(error), \(error.userInfo)")
                            }
                            self.sections.removeAll(keepingCapacity: false)
                            self.sections.append(Section(name: memberName, gender: gender, items: dependentsArray, relationship: relationArray, genderArray: genderArray, policyNo: policyNoArray, nationality: nationalityArray, mobile: mobileArray, email: emailArray))
                            self.refreshControl1.endRefreshing()
                            self.tableView.reloadData()
                            return
                        }
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                    self.refreshControl1.endRefreshing()
                    self.tableView.reloadData()
                }
            case .Error(let message):
                self.refreshControl1.endRefreshing()
                self.alertDialog (heading: "", message: message);
            default:
                self.refreshControl1.endRefreshing()
                LoadingIndicatorView.hideInMain()
            }
        }
    }
    
    func alertDialog (heading: String, message: String) {
        OperationQueue.main.addOperation {
            self.refreshControl1.endRefreshing()
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
//
// MARK: - View Controller DataSource and Delegate
//
extension MemberDetails {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MemberChild
        cell.name?.text = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        cell.relation?.text = sections[(indexPath as NSIndexPath).section].relationship[(indexPath as NSIndexPath).row]
        
        cell.name?.text = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        let relation = sections[(indexPath as NSIndexPath).section].relationship[(indexPath as NSIndexPath).row]
        if (relation == "S") {
            cell.relation?.text = "Son"
            cell.child_icon.image = UIImage(named: "child-male")
        } else if (relation == "D") {
            cell.relation?.text = "Daughter"
            cell.child_icon.image = UIImage(named: "child-female")
        } else if (relation == "W") {
            cell.relation?.text = "Wife"
            cell.child_icon.image = UIImage(named: "female")
        } else if (relation == "H") {
            cell.relation?.text = "Husband"
            cell.child_icon.image = UIImage(named: "male")
        } else {
            cell.relation?.text = relation
            cell.child_icon.image = UIImage(named: "member_icon")
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[(indexPath as NSIndexPath).section].collapsed! ? 0 : 44.0
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "MemberGroup")
        let header = cell as! MemberGroup
        header.name.text = sections[section].name
        if (sections[section].gender == "M") {
            header.group_icon.image = UIImage(named: "male")
        } else if (sections[section].gender == "F") {
            header.group_icon.image = UIImage(named: "female")
        } else {
            header.group_icon.image = UIImage(named: "group_icon")
        }
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0
    }
    
    // click cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let appDelegate = UIApplication.shared.delegate
        let name = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        var relation = sections[(indexPath as NSIndexPath).section].relationship[(indexPath as NSIndexPath).row]
        let policy = sections[(indexPath as NSIndexPath).section].policyNo[(indexPath as NSIndexPath).row]
        var gender = sections[(indexPath as NSIndexPath).section].genderArray[(indexPath as NSIndexPath).row]
        let nationality = sections[(indexPath as NSIndexPath).section].nationality[(indexPath as NSIndexPath).row]
        let mobile = sections[(indexPath as NSIndexPath).section].mobile[(indexPath as NSIndexPath).row]
        let email = sections[(indexPath as NSIndexPath).section].email[(indexPath as NSIndexPath).row]
        
        if (relation == "S") {
            relation = "Son"
        } else if (relation == "D") {
            relation = "Daughter"
        } else if (relation == "W") {
            relation = "Wife"
        } else if (relation == "H") {
            relation = "Husband"
        }
        
        if (gender == "M") {
            gender = "Male"
        } else {
            gender = "Female"
        }
        
        let vc = CustomAlertMember()
        vc.policy = policy
        vc.relation = relation
        vc.name = name
        vc.gender = gender
        vc.nationality = nationality
        vc.mobile = mobile
        vc.email = email
        (appDelegate?.window??.rootViewController)?.present(vc, animated: true, completion: nil)
    }
    
}
