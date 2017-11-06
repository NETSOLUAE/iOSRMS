//
//  EbPolicyDetail.swift
//  RMS
//
//  Created by Mac Mini on 11/4/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import CoreData

//
// MARK: - Section Data Structure
//
struct SectionEbPolicy {
    var name: String!
    var companyNameArray: [String]!
    var staffIDArray: [String]!
    var policyNoArray: [String]!
    var dateArray: [String]!
    var collapsed: Bool!
    
    init(name: String, companyNameArray: [String], staffIDArray: [String], policyNoArray: [String], dateArray: [String], collapsed: Bool = false) {
        self.name = name
        self.companyNameArray = companyNameArray
        self.staffIDArray = staffIDArray
        self.policyNoArray = policyNoArray
        self.dateArray = dateArray
        self.collapsed = collapsed
    }
}

class EbPolicyDetail: UITableViewController, IndicatorInfoProvider {
    var itemInfo: IndicatorInfo = " Policy Details"
    var sections = [SectionEbPolicy]()
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
        let nib = UINib(nibName: "EbPolicyDetailGroup", bundle: Bundle.main)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "EbPolicyDetailGroup")
        tableView.register(UINib(nibName: "EbPolicyDetailChild", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
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
        refreshControl1.attributedTitle = NSAttributedString(string: "Refershing Policy Details ...")
        // Configure Refresh Control
        self.refreshControl1.addTarget(self, action: #selector(self.refreshMemberDetails(refreshControl:)), for: .valueChanged)
        
        var companyNameArray = Array<String>()
        var saffIDArray = Array<String>()
        var policyNoArray = Array<String>()
        var dateArray = Array<String>()
        
        // Initialize the sections array
        let managedContext =
            sharedInstance.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "EB_POLICY_GROUP")
        do {
            let people = try managedContext.fetch(fetchRequest)
            for people in people {
                let memberName = (people.value(forKey: "memberNameEb") ?? "") as! String;
                let memberId = (people.value(forKey: "memberTypeEb") ?? "") as! String;
                let relation = (people.value(forKey: "relationshipTypeEb") ?? "") as! String;
                let name = "\(memberName)\(" (")\(relation)\(")")"
                var dependents  = [EB_POLICY_CHILD]() // Where Locations = your NSManaged Class
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EB_POLICY_CHILD")
                do {
                    dependents = try managedContext.fetch(fetchRequest) as! [EB_POLICY_CHILD]
                    for dependents in dependents {
                        
                        let memberID = dependents.memberIdEb!
                        if (memberId == memberID) {
                            companyNameArray.append(dependents.companyNameEb!)
                            saffIDArray.append(dependents.staffIdEb!)
                            policyNoArray.append(dependents.policyRefEb!)
                            var date = ""
                            var startDate = dependents.startDateEb ?? ""
                            var endDate = dependents.endDateEb ?? ""
                            if (startDate != "" && endDate != "") {
                                startDate = startDate.replacingOccurrences(of: "-", with: "/")
                                endDate = endDate.replacingOccurrences(of: "-", with: "/")
                                date = "\(startDate)\(" - ")\(endDate)"
                            } else if (startDate != "" ) {
                                startDate = startDate.replacingOccurrences(of: "-", with: "/")
                                date = startDate
                            } else if (endDate != "") {
                                endDate = endDate.replacingOccurrences(of: "-", with: "/")
                                date = endDate
                            }
                            dateArray.append(date)
                        }
                    }
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                sections.append(SectionEbPolicy(name: name, companyNameArray: companyNameArray, staffIDArray: saffIDArray, policyNoArray: policyNoArray, dateArray: dateArray))
                companyNameArray.removeAll()
                saffIDArray.removeAll()
                policyNoArray.removeAll()
                dateArray.removeAll()
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
                self.EbPolicyDetails(actionId: "staff_policy_summary", phoneNumber: mobileNumber!, staffID: staffID!, clientID: clientID!)
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
    
    func EbPolicyDetails(actionId: String, phoneNumber: String, staffID: String, clientID: String) -> Void {
        
        let endPoint: String = {
            return "\(constants.BASE_URL)?action_id=\(actionId)&mobile_no=\(phoneNumber)&staff_id=\(staffID)&client_no=\(clientID)"
        }()
        
        self.webserviceManager.login(type: "ebPolicy", endPoint: endPoint) { (result) in
            switch result {
            case .SuccessSingle(let data, let require_update):
                if (require_update == "yes") {
                    self.sharedInstance.clearEbPolicyDetails()
                    _ = self.sharedInstance.createEbPolicyEntityFrom(dictionary: data)
                    self.sections.removeAll(keepingCapacity: false)
                    
                    var companyNameArray = Array<String>()
                    var saffIDArray = Array<String>()
                    var policyNoArray = Array<String>()
                    var dateArray = Array<String>()
                    
                    // Initialize the sections array
                    let managedContext =
                        self.sharedInstance.persistentContainer.viewContext
                    
                    let fetchRequest =
                        NSFetchRequest<NSManagedObject>(entityName: "EB_POLICY_GROUP")
                    do {
                        let people = try managedContext.fetch(fetchRequest)
                        for people in people {
                            let memberName = (people.value(forKey: "memberNameEb") ?? "") as! String;
                            let memberId = (people.value(forKey: "memberTypeEb") ?? "") as! String;
                            let relation = (people.value(forKey: "relationshipTypeEb") ?? "") as! String;
                            let name = "\(memberName)\(" (")\(relation)\(")")"
                            var dependents  = [EB_POLICY_CHILD]() // Where Locations = your NSManaged Class
                            
                            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EB_POLICY_CHILD")
                            do {
                                dependents = try managedContext.fetch(fetchRequest) as! [EB_POLICY_CHILD]
                                for dependents in dependents {
                                    let memberID = dependents.memberIdEb!
                                    if (memberId == memberID) {
                                        companyNameArray.append(dependents.companyNameEb!)
                                        saffIDArray.append(dependents.staffIdEb!)
                                        policyNoArray.append(dependents.policyRefEb!)
                                        var date = ""
                                        var startDate = dependents.startDateEb ?? ""
                                        var endDate = dependents.endDateEb ?? ""
                                        if (startDate != "" && endDate != "") {
                                            startDate = startDate.replacingOccurrences(of: "-", with: "/")
                                            endDate = endDate.replacingOccurrences(of: "-", with: "/")
                                            date = "\(startDate)\(" - ")\(endDate)"
                                        } else if (startDate != "" ) {
                                            startDate = startDate.replacingOccurrences(of: "-", with: "/")
                                            date = startDate
                                        } else if (endDate != "") {
                                            endDate = endDate.replacingOccurrences(of: "-", with: "/")
                                            date = endDate
                                        }
                                        dateArray.append(date)
                                    }
                                }
                            } catch let error as NSError {
                                print("Could not fetch. \(error), \(error.userInfo)")
                            }
                            self.sections.append(SectionEbPolicy(name: name, companyNameArray: companyNameArray, staffIDArray: saffIDArray, policyNoArray: policyNoArray, dateArray: dateArray))
                            companyNameArray.removeAll()
                            saffIDArray.removeAll()
                            policyNoArray.removeAll()
                            dateArray.removeAll()
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
extension EbPolicyDetail {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].staffIDArray.count
    }
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EbPolicyDetailChild
        cell.companyName?.text = sections[(indexPath as NSIndexPath).section].companyNameArray[(indexPath as NSIndexPath).row]
        cell.EbStaffId?.text = sections[(indexPath as NSIndexPath).section].staffIDArray[(indexPath as NSIndexPath).row]
        cell.EbPolicyRef?.text = sections[(indexPath as NSIndexPath).section].policyNoArray[(indexPath as NSIndexPath).row]
        cell.EbEffectiveDate?.text = sections[(indexPath as NSIndexPath).section].dateArray[(indexPath as NSIndexPath).row]
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[(indexPath as NSIndexPath).section].collapsed! ? 0 : 124.0
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "EbPolicyDetailGroup")
        let header = cell as! EbPolicyDetailGroup
        let name = sections[section].name ?? ""
        if (name.contains("(P)")) {
            header.contentView.backgroundColor = UIColor().HexToColor(hexString: "#f1f1f1", alpha: 1.0)
        } else {
            header.contentView.backgroundColor = UIColor().HexToColor(hexString: "#fafafa", alpha: 1.0)
        }
        header.name.text = name
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0
    }
}
