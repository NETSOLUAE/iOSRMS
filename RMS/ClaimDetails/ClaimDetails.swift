//
//  ClaimDetails.swift
//  RMS
//
//  Created by Mac Mini on 7/1/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ClaimDetails: UITableViewController, IndicatorInfoProvider {
    
    var itemInfo: IndicatorInfo = "Claim Details"
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCandies = [CLAIM_DETAILS]()
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
        tableView.register(UINib(nibName: "claimdetails", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
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
        refreshControl1.attributedTitle = NSAttributedString(string: "Refershing Claim ...")
        // Configure Refresh Control
        self.refreshControl1.addTarget(self, action: #selector(self.refreshClaims(refreshControl:)), for: .valueChanged)
        // trigger load
        load()
    }
    
    func refreshClaims(refreshControl: UIRefreshControl) {
        
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
            self.claimDetails(actionId: "claim_status", staffID: staffID, clientID: clientID)
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
    lazy var fetchedResultsController: NSFetchedResultsController<CLAIM_DETAILS> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<CLAIM_DETAILS> = CLAIM_DETAILS.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "member_name", ascending: false)]
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ClaimDetailsView
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let candy: CLAIM_DETAILS
        if searchController.isActive && searchController.searchBar.text != "" {
            candy = filteredCandies[indexPath.row]
        } else {
            candy = fetchedResultsController.object(at: indexPath)
        }
        
        cell.claimNo?.text = candy.claim_no
        cell.regDate?.text = candy.reg_date
        cell.status?.text = candy.status
        cell.patientName?.text = candy.member_name! + " (" + candy.member_type! + ")"
        if (candy.status == "Approved"){
            cell.status?.textColor = UIColor().HexToColor(hexString: "#f9d854", alpha: 1.0)
        } else if (candy.status == "Settled") {
            cell.status?.textColor = UIColor().HexToColor(hexString: "#10783A", alpha: 1.0)
        } else if (candy.status == "Registered") {
            cell.status?.textColor = UIColor().HexToColor(hexString: "#126FFA", alpha: 1.0)
        } else if (candy.status == "Rejected") {
            cell.status?.textColor = UIColor().HexToColor(hexString: "#FB0008", alpha: 1.0)
        } else if (candy.status == "Queried") {
            cell.status?.textColor = UIColor().HexToColor(hexString: "#303F9F", alpha: 1.0)
        } else if (candy.status == "Cancelled") {
            cell.status?.textColor = UIColor().HexToColor(hexString: "#FB0008", alpha: 1.0)
        }
        return cell
    }
    
    // click cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let claimDetails: CLAIM_DETAILS
        let appDelegate = UIApplication.shared.delegate
        if searchController.isActive && searchController.searchBar.text != "" {
            self.searchController.dismiss(animated: false) {
                // Do what you want here like perform segue or present
                self.searchController.searchBar.text = ""
                self.searchController.searchBar.showsCancelButton = false
            }
            claimDetails = self.filteredCandies[indexPath.row]
        } else {
            claimDetails = fetchedResultsController.object(at: indexPath)
        }
        
        let vc = CustomAlertClaims()
        vc.policy = claimDetails.policy_no!
        vc.claimNo1 = claimDetails.claim_no!
        vc.diagnosis1 = claimDetails.diagnosis!
        vc.treatmentDate1 = claimDetails.treatment_date!
        vc.status1 = claimDetails.status!
        vc.claimedAmount1 = claimDetails.claimed_mount!
        vc.approvedAmount1 = claimDetails.approved_amount!
        vc.excess1 = claimDetails.excess!
        vc.disallo1 = claimDetails.disallowance!
        vc.settledRO1 = claimDetails.settled_amount_ro!
        vc.modeOfPayment1 = claimDetails.mode_of_payment!
        vc.chequeNo1 = claimDetails.cheque_no!
        vc.settled1 = claimDetails.settled_amount!
        vc.remarks1 = claimDetails.remarks!
        (appDelegate?.window??.rootViewController)?.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool){
        tableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        var locations  = [CLAIM_DETAILS]() // Where Locations = your NSManaged Class
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CLAIM_DETAILS")
        do {
            locations = try managedContext.fetch(fetchRequest) as! [CLAIM_DETAILS]
            filteredCandies = locations.filter { candy in
                return (candy.claim_no?.contains(searchText.uppercased()))!
            }
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func claimDetails(actionId: String, staffID: String, clientID: String) -> Void {
        
        let endPoint: String = {
            return "\(constants.BASE_URL)?action_id=\(actionId)&staff_id=\(staffID)&client_no=\(clientID)"
        }()
        
        self.webserviceManager.login(type: "double", endPoint: endPoint) { (result) in
            LoadingIndicatorView.hideInMain()
            switch result {
            case .Success(let data, let require_update):
                if (require_update == "yes") {
                    self.sharedInstance.clearClaimDetails()
                    self.sharedInstance.saveInClaimDataWith(array: [data])
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

extension ClaimDetails: NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
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

extension UIColor{
    func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}
