//
//  Information.swift
//  RMS
//
//  Created by Mac Mini on 7/1/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import CoreData

class Information: UITableViewController, IndicatorInfoProvider, UIDocumentInteractionControllerDelegate {
    
    var itemInfo: IndicatorInfo = "Information"
    let sharedInstance = CoreDataManager.sharedInstance;
    
    init(style: UITableViewStyle, itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "InformationView", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
        tableView.estimatedRowHeight = 70.0
        tableView.rowHeight = 55.0
        tableView.allowsSelection = true
        tableView.backgroundColor = .white
        tableView.preservesSuperviewLayoutMargins = false
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        tableView.tableFooterView = UIView (frame: CGRect.zero)
        // trigger load
        load()
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
    lazy var fetchedResultsController: NSFetchedResultsController<PDF> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<PDF> = PDF.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pdf_name", ascending: false)]
        
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
        return quotes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InformationView
        
        let pdfText = fetchedResultsController.object(at: indexPath)
        
        cell.pdfHeading?.text = pdfText.pdf_name
        cell.selectionStyle = .none
        return cell
    }
    
    //swipe and delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if(editingStyle == .delete){
            
            // Fetch Quote
            let quote = fetchedResultsController.object(at: indexPath)
            
            // Delete Quote
            quote.managedObjectContext?.delete(quote)
        }
    }
    
    // click cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        // Fetch Quote
        let quote = fetchedResultsController.object(at: indexPath)
        
        DispatchQueue.main.async(execute: {
            /* Do some heavy work (you are now on a background queue) */
            LoadingIndicatorView.show("Downloading " + quote.pdf_name!)
        });
        self.downloadPdf(pdfName: quote.pdf_name!, pdfUrl: quote.pdf_link!)
    }
    
    override func viewDidAppear(_ animated: Bool){
        tableView.reloadData()
    }
    
    func downloadPdf(pdfName: String, pdfUrl: String){
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            
            // Create destination URL
            let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
            let destinationFileUrl = documentsUrl.appendingPathComponent(pdfName + ".pdf")
            
            //Create URL to the source file you want to download
            let fileURL = URL(string: pdfUrl)
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            
            let request = URLRequest(url:fileURL!)
            
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Successfully downloaded. Status code: \(statusCode)")
                    }
                    
                    do {
                        if(FileManager.default.fileExists(atPath: (destinationFileUrl.path))){
                            try! FileManager.default.removeItem(at: destinationFileUrl)
                        }
                        try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                        
                        let viewer = UIDocumentInteractionController(url: URL(fileURLWithPath: destinationFileUrl.path))
                        viewer.delegate = self
                        viewer.presentPreview(animated: true)
                        DispatchQueue.main.sync(execute: {
                            /* stop the activity indicator (you are now on the main queue again) */
                            LoadingIndicatorView.hide()
                        });
                    } catch (let writeError) {
                        print("Error creating a file \(destinationFileUrl) : \(writeError)")
                    }
                    
                } else {
                    print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "");
                }
            }
            task.resume()
            
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

}

extension Information: NSFetchedResultsControllerDelegate {
    
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
}
