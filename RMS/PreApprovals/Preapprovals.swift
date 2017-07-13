//
//  Preapprovals.swift
//  RMS
//
//  Created by Mac Mini on 7/1/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class Preapprovals: UITableViewController, IndicatorInfoProvider {
    
    var itemInfo: IndicatorInfo = "Preapproval"
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCandies = [PRE_APPROVALS]()
    let refreshControl1 = UIRefreshControl()
    let constants = Constants()
    
    init(style: UITableViewStyle, itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(style: style)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "preapprovals", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
        tableView.estimatedRowHeight = 70.0
        tableView.rowHeight = 55.0
        tableView.allowsSelection = true
        tableView.backgroundColor = .white
        tableView.preservesSuperviewLayoutMargins = false
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        tableView.tableFooterView = UIView (frame: CGRect.zero)
        
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        definesPresentationContext = false
        tableView.tableHeaderView = searchController.searchBar
        
        // Add to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl1
        } else {
            tableView.addSubview(refreshControl1)
        }
        refreshControl1.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl1.attributedTitle = NSAttributedString(string: "Refershing PreApprovals ...")
        // Configure Refresh Control
        self.refreshControl1.addTarget(self, action: #selector(self.refreshPreapproval(refreshControl:)), for: .valueChanged)
        // trigger load
        load()
    }
    
    func refreshPreapproval(refreshControl: UIRefreshControl) {
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
                let client_id = (people.value(forKey: "client_id") ?? "") as! String;
                self.preApproval(actionId: "pre_approval", staffID: staff_id, clientID: client_id)
                return
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //persistant container
    let persistentContainer = NSPersistentContainer.init(name: "RMS")
    
    //
    lazy var fetchedResultsController: NSFetchedResultsController<PRE_APPROVALS> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<PRE_APPROVALS> = PRE_APPROVALS.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "patient_name", ascending: false)]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managerContext = appDelegate.persistentContainer.viewContext
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managerContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        
        return fetchedResultsController
    }()
    
    func load(){
        //persistant container
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
            } else {
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let quotes = fetchedResultsController.fetchedObjects else {
            return 0
        }
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredCandies.count
        }
        return quotes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PreApprovalsView
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let preApprovals: PRE_APPROVALS
        if searchController.isActive && searchController.searchBar.text != "" {
            preApprovals = filteredCandies[indexPath.row]
        } else {
            preApprovals = fetchedResultsController.object(at: indexPath)
        }
        
        cell.policyNo?.text = preApprovals.pol_ref
        cell.regDate?.text = preApprovals.entry_dt
        cell.status?.text = preApprovals.status
        cell.patientName?.text = preApprovals.patient_name
        return cell
    }
    
    // click cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let preapproval: PRE_APPROVALS
        let appDelegate = UIApplication.shared.delegate
        if searchController.isActive && searchController.searchBar.text != "" {
            self.searchController.dismiss(animated: false) {
                // Do what you want here like perform segue or present
                self.searchController.searchBar.text = ""
                self.searchController.searchBar.showsCancelButton = false
            }
            preapproval = self.filteredCandies[indexPath.row]
        } else {
            preapproval = fetchedResultsController.object(at: indexPath)
        }
        
        let vc = CustomPreapproval()
        vc.patientId1 = preapproval.memberid!
        vc.patientName1 = preapproval.patient_name!
        vc.staffId1 = preapproval.staff_id!
        vc.staffName1 = preapproval.staff_name!
        vc.policyRef1 = preapproval.pol_ref!
        vc.entryDate1 = preapproval.entry_dt!
        vc.diagnosis1 = preapproval.diagnosis!
        vc.place1 = preapproval.place_code!
        vc.hospitalName1 = preapproval.hospital_name!
        vc.status1 = preapproval.status!
        vc.preapprovalNo1 = preapproval.pre_approvalno!
        vc.preApprovalDate1 = preapproval.pre_approvaldt!
        vc.remarks1 = preapproval.remarks!
        (appDelegate?.window??.rootViewController)?.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool){
        tableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        var locations  = [PRE_APPROVALS]() // Where Locations = your NSManaged Class
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PRE_APPROVALS")
        do {
            locations = try managedContext.fetch(fetchRequest) as! [PRE_APPROVALS]
            filteredCandies = locations.filter { candy in
                return (candy.patient_name?.contains(searchText.uppercased()))!
            }
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
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
                                self.tableView.reloadData()
                                self.refreshControl1.endRefreshing()
                                return
                            } else {
                                self.tableView.reloadData()
                                self.refreshControl1.endRefreshing()
                                return
                            }
                        } else if (status == "fail") {
                            self.alertDialog (heading: "", message: self.constants.errorMessage);
                            return
                        } else {
                            self.alertDialog (heading: "", message: self.constants.errorMessage);
                            return
                        }
                        
                    } catch {
                        self.alertDialog (heading: "", message: self.constants.errorMessage);
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
            self.refreshControl1.endRefreshing()
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension Preapprovals: NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            //            if let indexPath = indexPath, let cell = claimDetailsTable.cellForRow(at: indexPath) {
            //                configureCell(cell, at: indexPath)
            //                //get intervento
            //                let claimDetails = fetchedResultsController.object(at: indexPath)
            //
            //                //fill the cell
            //                cell.claimNo?.text = claimDetails.claim_no
            //                cell.regDate?.text = claimDetails.reg_date
            //                cell.status?.text = claimDetails.status
            //                cell.patientName?.text = claimDetails.member_name! + " (" + claimDetails.member_type! + ")"
            //            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
