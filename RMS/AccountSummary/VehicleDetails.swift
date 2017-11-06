//
//  VehicleDetails.swift
//  RMS
//
//  Created by Mac Mini on 8/23/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import CoreData

class VehicleDetails: UIViewController {
    
    @IBOutlet weak var vehicleNumber: UILabel!
    @IBOutlet weak var expDate: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var outAmountHeading: UILabel!
    @IBOutlet weak var outAmount: UILabel!
    @IBOutlet weak var totalPremium: UILabel!
    @IBOutlet weak var nextInstallment: UILabel!
    @IBOutlet weak var installmentPaid: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalPremiumView: UIView!
    @IBOutlet weak var nextInstallmentHeading: UILabel!
    @IBOutlet weak var installmentsPaidView: UIView!
    @IBOutlet weak var installmentsDetailsView: UIView!
    
    var installments = [POLICY_INSTALLMENT]()
    let constants = Constants()
    let webserviceManager = WebserviceManager();
    let sharedInstance = CoreDataManager.sharedInstance;
    let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
    
    //persistant container
    let persistentContainer = NSPersistentContainer.init(name: "RMS")
    
    //
    lazy var fetchedResultsController: NSFetchedResultsController<POLICY_INSTALLMENT> = {
        let fetchRequest: NSFetchRequest<POLICY_INSTALLMENT> = POLICY_INSTALLMENT.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managerContext = self.sharedInstance.persistentContainer.viewContext
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managerContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        installmentsDetailsView.isHidden = true
        if (currentSelection.name == "salary") {
            outAmountHeading.text = "Outstanding Amount"
            totalPremiumView.isHidden = false
            nextInstallmentHeading.isHidden = false
            nextInstallment.isHidden = false
            installmentsPaidView.isHidden = false
        } else if (currentSelection.name == "lines") {
            outAmountHeading.text = "Total Premium Charged"
            totalPremiumView.isHidden = true
            nextInstallmentHeading.isHidden = true
            nextInstallment.isHidden = true
            installmentsPaidView.isHidden = true
        }
    }
    
    @IBAction func viewPressed(_ sender: Any) {
        installmentsDetailsView.isHidden = false
    }
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (currentSelection.name == "salary") {
            installmentsDetailsView.isHidden = true
            self.tableView.register(UINib(nibName: "InstallmentView", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
            self.tableView.estimatedRowHeight = 70.0
            self.tableView.rowHeight = 55.0
            self.tableView.allowsSelection = true
            self.tableView.backgroundColor = .white
            self.tableView.preservesSuperviewLayoutMargins = false
            self.tableView.layoutMargins = UIEdgeInsets.zero
            self.tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
            self.tableView.tableFooterView = UIView (frame: CGRect.zero)
            // trigger load
            load()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if (currentSelection.name == "salary") {
            installments.removeAll()
            self.tableView.reloadData()
            installmentsDetailsView.isHidden = true
        }
    }
}

extension VehicleDetails : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AccountSummaryView.height()
    }
    
    // click cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView == scrollView {
            
        }
    }
}

extension VehicleDetails : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InstallmentView
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let policyInstallment: POLICY_INSTALLMENT
        policyInstallment = installments[indexPath.row]
        cell.amount?.text = (policyInstallment.amount ?? "0") + " OMR"
        cell.regDate?.text = policyInstallment.date
        cell.status?.text = policyInstallment.status
        if (installments.first?.status == "Active"){
            cell.status?.textColor = UIColor().HexToColor(hexString: "#10783A", alpha: 1.0)
        }  else {
            cell.status?.textColor = UIColor().HexToColor(hexString: "#FB0008", alpha: 1.0)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return installments.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
