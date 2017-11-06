//
//  PolicyDetails.swift
//  RMS
//
//  Created by Mac Mini on 8/22/17.
//  Copyright © 2017 Netsol. All rights reserved.
//
import UIKit
import CoreData

//
// MARK: - Section Data Structure
//
struct PolicySection {
    var name: String!
    var items: [String]!
    var relationship: [String]!
    var collapsed: Bool!
    
    init(name: String, items: [String],  relationship: [String], collapsed: Bool = false) {
        self.name = name
        self.items = items
        self.relationship = relationship
        self.collapsed = collapsed
    }
}

class PolicyDetails: UITableViewController, IndicatorInfoProvider {
    var itemInfo: IndicatorInfo = "Policy Details"
    var entityName = ""
    var policyName = ""
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
        let nib = UINib(nibName: "PolicyGroup", bundle: Bundle.main)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "PolicyGroup")
        tableView.register(UINib(nibName: "PolicyChild", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
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
        self.refreshControl1.addTarget(self, action: #selector(self.refreshPolicyDetails(refreshControl:)), for: .valueChanged)
        
        
        var dependentsArray = Array<String>()
        var relationArray = Array<String>()
        let genderArray = Array<String>()
        let policyNo = Array<String>()
        let nationality = Array<String>()
        let mobile = Array<String>()
        let email = Array<String>()
        
        
        if (currentSelection.name == "salary") {
            
            // Initialize the sections array
            let managedContext =
                sharedInstance.persistentContainer.viewContext
            
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS_SALARY")
            do {
                let people = try managedContext.fetch(fetchRequest)
                for people in people {
                    let memberName = (people.value(forKey: "staffName") ?? "") as! String;
                    var dependents  = [STAFF_DETAILS_POLICY]() // Where Locations = your NSManaged Class
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "STAFF_DETAILS_POLICY")
                    do {
                        dependents = try managedContext.fetch(fetchRequest) as! [STAFF_DETAILS_POLICY]
                        for dependents in dependents {
                            dependentsArray.append(dependents.policyNo!)
                            relationArray.append(dependents.startDate! + " - " + dependents.endDate!)
                        }
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                    sections.append(Section(name: memberName, gender: "", items: dependentsArray, relationship: relationArray, genderArray: genderArray, policyNo: policyNo, nationality: nationality, mobile: mobile, email: email))
                    return
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        } else if (currentSelection.name == "lines") {
            
            // Initialize the sections array
            let managedContext =
                sharedInstance.persistentContainer.viewContext
            
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS_LINES")
            do {
                let people = try managedContext.fetch(fetchRequest)
                for people in people {
                    let memberName = (people.value(forKey: "staffName") ?? "") as! String;
                    var dependents  = [STAFF_DETAILS_POLICY_LINES]() // Where Locations = your NSManaged Class
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "STAFF_DETAILS_POLICY_LINES")
                    do {
                        dependents = try managedContext.fetch(fetchRequest) as! [STAFF_DETAILS_POLICY_LINES]
                        for dependents in dependents {
                            dependentsArray.append(dependents.policyNo!)
                            relationArray.append(dependents.startDate! + " - " + dependents.endDate!)
                        }
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                    sections.append(Section(name: memberName, gender: "", items: dependentsArray, relationship: relationArray, genderArray: genderArray, policyNo: policyNo, nationality: nationality, mobile: mobile, email: email))
                    return
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func refreshPolicyDetails(refreshControl: UIRefreshControl) {
        if (currentSelection.name == "salary") {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
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
                
                // Initialize the sections array
                var dependentsArray = Array<String>()
                var relationArray = Array<String>()
                let genderArray = Array<String>()
                let policyNo = Array<String>()
                let nationality = Array<String>()
                let mobile = Array<String>()
                let email = Array<String>()
                let managedContext =
                    self.sharedInstance.persistentContainer.viewContext
                
                let fetchRequest =
                    NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS_LINES")
                do {
                    let people = try managedContext.fetch(fetchRequest)
                    for people in people {
                        let memberName = (people.value(forKey: "staffName") ?? "") as! String;
                        var dependents  = [STAFF_DETAILS_POLICY_LINES]() // Where Locations = your NSManaged Class
                        
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "STAFF_DETAILS_POLICY_LINES")
                        do {
                            dependents = try managedContext.fetch(fetchRequest) as! [STAFF_DETAILS_POLICY_LINES]
                            for dependents in dependents {
                                dependentsArray.append(dependents.policyNo!)
                                relationArray.append(dependents.startDate! + " - " + dependents.endDate!)
                            }
                        } catch let error as NSError {
                            print("Could not fetch. \(error), \(error.userInfo)")
                        }
                        self.sections.removeAll(keepingCapacity: false)
                        self.sections.append(Section(name: memberName, gender: "", items: dependentsArray, relationship: relationArray, genderArray: genderArray, policyNo: policyNo, nationality: nationality, mobile: mobile, email: email))
                        self.refreshControl1.endRefreshing()
                        self.tableView.reloadData()
                        return
                    }
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
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
                
                // Initialize the sections array
                var dependentsArray = Array<String>()
                var relationArray = Array<String>()
                let genderArray = Array<String>()
                let policyNo = Array<String>()
                let nationality = Array<String>()
                let mobile = Array<String>()
                let email = Array<String>()
                let managedContext =
                    self.sharedInstance.persistentContainer.viewContext
                
                let fetchRequest =
                    NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS_SALARY")
                do {
                    let people = try managedContext.fetch(fetchRequest)
                    for people in people {
                        let memberName = (people.value(forKey: "staffName") ?? "") as! String;
                        var dependents  = [STAFF_DETAILS_POLICY]() // Where Locations = your NSManaged Class
                        
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "STAFF_DETAILS_POLICY")
                        do {
                            dependents = try managedContext.fetch(fetchRequest) as! [STAFF_DETAILS_POLICY]
                            for dependents in dependents {
                                dependentsArray.append(dependents.policyNo!)
                                relationArray.append(dependents.startDate! + " - " + dependents.endDate!)
                            }
                        } catch let error as NSError {
                            print("Could not fetch. \(error), \(error.userInfo)")
                        }
                        self.sections.removeAll(keepingCapacity: false)
                        self.sections.append(Section(name: memberName, gender: "", items: dependentsArray, relationship: relationArray, genderArray: genderArray, policyNo: policyNo, nationality: nationality, mobile: mobile, email: email))
                        self.refreshControl1.endRefreshing()
                        self.tableView.reloadData()
                        return
                    }
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
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
extension PolicyDetails {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PolicyChild
        cell.policyNo?.text = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        cell.period?.text = sections[(indexPath as NSIndexPath).section].relationship[(indexPath as NSIndexPath).row]
        
        cell.policyNo?.text = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        cell.period?.text=sections[(indexPath as NSIndexPath).section].relationship[(indexPath as NSIndexPath).row]
        cell.imageView?.image = UIImage(named: "member_icon")
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[(indexPath as NSIndexPath).section].collapsed! ? 0 : 44.0
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "PolicyGroup")
        let header = cell as! PolicyGroup
        header.name.text = sections[section].name
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
}
