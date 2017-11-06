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
    var staffName = ""
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCandies = [PRE_APPROVALS]()
    let refreshControl1 = UIRefreshControl()
    let constants = Constants()
    let webserviceManager = WebserviceManager();
    let sharedInstance = CoreDataManager.sharedInstance;
    let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
    
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
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
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
        if searchController.isActive && searchController.searchBar.text != "" {
            self.searchController.dismiss(animated: false) {
                // Do what you want here like perform segue or present
                self.searchController.searchBar.text = ""
                self.searchController.searchBar.showsCancelButton = false
            }
        }
        
        var results : [STAFF_DETAILS]
        let studentUniversityFetchRequest: NSFetchRequest<STAFF_DETAILS>  = STAFF_DETAILS.fetchRequest()
        studentUniversityFetchRequest.returnsObjectsAsFaults = false
        do {
            results = try self.managedContext.fetch(studentUniversityFetchRequest)
            let staffID = results.first!.staff_id ?? ""
            let clientID = results.first!.client_id ?? ""
            self.preApproval(actionId: "pre_approval", staffID: staffID, clientID: clientID)
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
        let managerContext = self.sharedInstance.persistentContainer.viewContext
        
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
        
        let managedContext =
            sharedInstance.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS")
        do {
            let people = try managedContext.fetch(fetchRequest)
            for people in people {
                self.staffName = (people.value(forKey: "member_name") ?? "") as! String;
                return
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
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
        let patientName = preApprovals.patient_name
        if (patientName == self.staffName) {
            cell.patientName?.text = preApprovals.patient_name! + " (P)"
        } else {
            cell.patientName?.text = preApprovals.patient_name! + " (D)"
        }
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
        
        let endPoint: String = {
            return "\(constants.BASE_URL)?action_id=\(actionId)&staff_id=\(staffID)&client_no=\(clientID)"
        }()
        
        self.webserviceManager.login(type: "double", endPoint: endPoint) { (result) in
            LoadingIndicatorView.hideInMain()
            switch result {
            case .Success(let data, let require_update):
                if (require_update == "yes") {
                    self.sharedInstance.clearPreApprovalDetails()
                    self.sharedInstance.saveInPreApprovalDataWith(array: [data])
                }
                self.tableView.reloadData()
                self.refreshControl1.endRefreshing()
            case .Error(let message):
                self.refreshControl1.endRefreshing()
                self.alertDialog (heading: "", message: message);
            default:
                self.refreshControl1.endRefreshing()
                self.alertDialog (heading: "", message: self.constants.errorMessage);
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
