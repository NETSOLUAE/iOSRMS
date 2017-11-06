//
//  AccountSummary.swift
//  RMS
//
//  Created by Mac Mini on 8/22/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class AccountSummary: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var tableView1: UITableView!
    var itemInfo: IndicatorInfo = IndicatorInfo(title: "Account Summary", image: UIImage(named: "account"), highlightedImage: UIImage(named: "account-selected"))
    var vehicleDetialsView: VehicleDetails!
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCandies = [ACCOUNT_SUMMARY]()
    var filteredLines = [ACCOUNT_SUMMARY_LINES]()
    let refreshControl1 = UIRefreshControl()
    let constants = Constants()
    let webserviceManager = WebserviceManager();
    let sharedInstance = CoreDataManager.sharedInstance;
    let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
    
    //persistant container
    let persistentContainer = NSPersistentContainer.init(name: "RMS")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView1.register(UINib(nibName: "AccountSummaryView", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
        self.tableView1.estimatedRowHeight = 70.0
        self.tableView1.rowHeight = 55.0
        self.tableView1.allowsSelection = true
        self.tableView1.backgroundColor = .white
        self.tableView1.preservesSuperviewLayoutMargins = false
        self.tableView1.layoutMargins = UIEdgeInsets.zero
        self.tableView1.separatorInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        self.tableView1.tableFooterView = UIView (frame: CGRect.zero)
        
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        definesPresentationContext = false
        self.tableView1.tableHeaderView = searchController.searchBar
        
        // Add to Table View
        if #available(iOS 10.0, *) {
            self.tableView1.refreshControl = refreshControl1
        } else {
            self.tableView1.addSubview(refreshControl1)
        }
        refreshControl1.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl1.attributedTitle = NSAttributedString(string: "Refershing Account Summary ...")
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
        if (currentSelection.name == "salary") {
            let managedContext =
                sharedInstance.persistentContainer.viewContext
            
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS_SALARY")
            do {
                let people = try managedContext.fetch(fetchRequest)
                for people in people {
                    let nationalID = (people.value(forKey: "nationalID") ?? "") as! String;
                    self.accountSummary(actionId: "vehicles", nationalId: nationalID)
                    return
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        } else if (currentSelection.name == "lines") {
            
            let managedContext =
                sharedInstance.persistentContainer.viewContext
            
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS_LINES")
            do {
                let people = try managedContext.fetch(fetchRequest)
                for people in people {
                    let nationalID = (people.value(forKey: "nationalID") ?? "") as! String;
                    self.accountSummary(actionId: "vehicles", nationalId: nationalID)
                    return
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    //
    lazy var fetchedResultsController: NSFetchedResultsController<ACCOUNT_SUMMARY> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<ACCOUNT_SUMMARY> = ACCOUNT_SUMMARY.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managerContext = self.sharedInstance.persistentContainer.viewContext
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managerContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        
        return fetchedResultsController
    }()
    
    lazy var fetchedResultsControllerLines: NSFetchedResultsController<ACCOUNT_SUMMARY_LINES> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<ACCOUNT_SUMMARY_LINES> = ACCOUNT_SUMMARY_LINES.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
        
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
                    if (currentSelection.name == "salary") {
                        try self.fetchedResultsController.performFetch()
                    } else if (currentSelection.name == "lines") {
                        try self.fetchedResultsControllerLines.performFetch()
                    }
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                
            }
        }
    }
    
    func vehicleBack(sender:UIButton) {
        self.tableView1.isHidden = false
        vehicleDetialsView.view.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool){
        tableView1.reloadData()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        if (currentSelection.name == "salary") {
            var locations  = [ACCOUNT_SUMMARY]() // Where Locations = your NSManaged Class
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ACCOUNT_SUMMARY")
            do {
                locations = try managedContext.fetch(fetchRequest) as! [ACCOUNT_SUMMARY]
                filteredCandies = locations.filter { candy in
                    return (candy.vehicleNumber?.contains(searchText.uppercased()))!
                }
                tableView1.reloadData()
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        } else if (currentSelection.name == "lines") {
            
            var locations  = [ACCOUNT_SUMMARY_LINES]() // Where Locations = your NSManaged Class
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ACCOUNT_SUMMARY_LINES")
            do {
                locations = try managedContext.fetch(fetchRequest) as! [ACCOUNT_SUMMARY_LINES]
                filteredLines = locations.filter { candy in
                    return (candy.vehicleNumber?.contains(searchText.uppercased()))!
                }
                tableView1.reloadData()
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func accountSummary(actionId: String, nationalId: String) -> Void {
        var params = ""
        if (currentSelection.name == "salary") {
            params = constants.BASE_URL_SALARY
        } else if (currentSelection.name == "lines") {
            params = constants.BASE_URL_LINES
        }
        let endPoint: String = {
            return "\(params)?action_id=\(actionId)&national_id=\(nationalId)"
        }()
        
        self.webserviceManager.login(type: "double", endPoint: endPoint) { (result) in
            LoadingIndicatorView.hideInMain()
            switch result {
            case .Success(let data, _):
                if (currentSelection.name == "salary") {
                    self.sharedInstance.clearAccountSummary()
                    self.sharedInstance.saveInAccountSummaryDataWith(array: [data])
                } else if (currentSelection.name == "lines") {
                    self.sharedInstance.clearAccountSummaryLines()
                    self.sharedInstance.saveInAccountSummaryLinesDataWith(array: [data])
                }
                self.tableView1.reloadData()
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

extension AccountSummary: NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView1.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView1.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView1.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView1.deleteRows(at: [indexPath], with: .fade)
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
                tableView1.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView1.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

extension AccountSummary : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AccountSummaryView.height()
    }
    
    // click cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        self.tableView1.isHidden = true
        if (currentSelection.name == "salary") {
            let accountSummary: ACCOUNT_SUMMARY
            if searchController.isActive && searchController.searchBar.text != "" {
                self.searchController.dismiss(animated: false) {
                    // Do what you want here like perform segue or present
                    self.searchController.searchBar.text = ""
                    self.searchController.searchBar.showsCancelButton = false
                }
                accountSummary = self.filteredCandies[indexPath.row]
            } else {
                accountSummary = fetchedResultsController.object(at: indexPath)
            }
            
            if let vehicleDetialsView = Bundle.main.loadNibNamed("VehicleDetails", owner: self, options: nil)?.first as? VehicleDetails {
                
                vehicleDetialsView.vehicleNumber.text = accountSummary.vehicleNumber ?? ""
                vehicleDetialsView.expDate.text = accountSummary.endDate ?? ""
                vehicleDetialsView.status.text = accountSummary.status ?? ""
                
                let outAmount = String(describing: accountSummary.outstandingAmount)
                if (outAmount == "") {
                    vehicleDetialsView.outAmount.text = String(describing: accountSummary.outstandingAmount)
                } else {
                    vehicleDetialsView.outAmount.text = String(describing: accountSummary.outstandingAmount) + " OMR"
                }
                
                let totalPremium = accountSummary.totalPremium ?? ""
                if (totalPremium == "") {
                    vehicleDetialsView.totalPremium.text = accountSummary.totalPremium ?? ""
                } else {
                    vehicleDetialsView.totalPremium.text = totalPremium + " OMR"
                }
                
                let nextInstallment = String(describing: accountSummary.nextInstallmentAmount)
                if (nextInstallment == "") {
                    vehicleDetialsView.nextInstallment.text = String(describing: accountSummary.nextInstallmentAmount)
                } else {
                    vehicleDetialsView.nextInstallment.text = String(describing: accountSummary.nextInstallmentAmount) + " OMR"
                }
                
                vehicleDetialsView.installmentPaid.text = "\(accountSummary.installment?.count ?? 0)"
                vehicleDetialsView.installments = Array(accountSummary.installment ?? []) as! [POLICY_INSTALLMENT]
                vehicleDetialsView.backButton.addTarget(self, action: #selector(self.vehicleBack(sender:)), for: UIControlEvents.touchUpInside)
                
                self.vehicleDetialsView = vehicleDetialsView
                self.view.addSubview(self.vehicleDetialsView.view)
            }
        } else if (currentSelection.name == "lines") {
            let accountSummary: ACCOUNT_SUMMARY_LINES
            if searchController.isActive && searchController.searchBar.text != "" {
                self.searchController.dismiss(animated: false) {
                    // Do what you want here like perform segue or present
                    self.searchController.searchBar.text = ""
                    self.searchController.searchBar.showsCancelButton = false
                }
                accountSummary = self.filteredLines[indexPath.row]
            } else {
                accountSummary = fetchedResultsControllerLines.object(at: indexPath)
            }
            
            if let vehicleDetialsView = Bundle.main.loadNibNamed("VehicleDetails", owner: self, options: nil)?.first as? VehicleDetails {
                
                vehicleDetialsView.vehicleNumber.text = accountSummary.vehicleNumber ?? ""
                vehicleDetialsView.expDate.text = accountSummary.endDate ?? ""
                vehicleDetialsView.status.text = accountSummary.status ?? ""
                
                let totalPremium = accountSummary.totalPremium ?? ""
                if (totalPremium == "") {
                    vehicleDetialsView.outAmount.text = accountSummary.totalPremium ?? ""
                } else {
                    vehicleDetialsView.outAmount.text = totalPremium + " OMR"
                }
//                vehicleDetialsView.outAmount.text = String(describing: accountSummary.outstandingAmount)
//                vehicleDetialsView.totalPremium.text = accountSummary.totalPremium ?? ""
//                vehicleDetialsView.nextInstallment.text = String(describing: accountSummary.nextInstallmentAmount)
                vehicleDetialsView.backButton.addTarget(self, action: #selector(self.vehicleBack(sender:)), for: UIControlEvents.touchUpInside)
                
                self.vehicleDetialsView = vehicleDetialsView
                self.view.addSubview(self.vehicleDetialsView.view)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView1 == scrollView {
            
        }
    }
}

extension AccountSummary : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AccountSummaryView
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if (currentSelection.name == "salary") {
            let candy: ACCOUNT_SUMMARY
            if searchController.isActive && searchController.searchBar.text != "" {
                candy = filteredCandies[indexPath.row]
            } else {
                candy = fetchedResultsController.object(at: indexPath)
            }
            
            cell.vehicleNo?.text = candy.vehicleNumber
            cell.regDate?.text = candy.endDate
            cell.status?.text = candy.status
            if (candy.status == "Active"){
                cell.status?.textColor = UIColor().HexToColor(hexString: "#10783A", alpha: 1.0)
            }  else {
                cell.status?.textColor = UIColor().HexToColor(hexString: "#FB0008", alpha: 1.0)
            }
        } else if (currentSelection.name == "lines") {
            let candy: ACCOUNT_SUMMARY_LINES
            if searchController.isActive && searchController.searchBar.text != "" {
                candy = filteredLines[indexPath.row]
            } else {
                candy = fetchedResultsControllerLines.object(at: indexPath)
            }
            
            cell.vehicleNo?.text = candy.vehicleNumber
            cell.regDate?.text = candy.endDate
            cell.status?.text = candy.status
            if (candy.status == "Active"){
                cell.status?.textColor = UIColor().HexToColor(hexString: "#10783A", alpha: 1.0)
            }  else {
                cell.status?.textColor = UIColor().HexToColor(hexString: "#FB0008", alpha: 1.0)
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentSelection.name == "salary") {
            guard let quotes = fetchedResultsController.fetchedObjects else {
                return 0
            }
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredCandies.count
            }
            return quotes.count
        } else if (currentSelection.name == "lines") {
            guard let quotes = fetchedResultsControllerLines.fetchedObjects else {
                return 0
            }
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredLines.count
            }
            return quotes.count
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

