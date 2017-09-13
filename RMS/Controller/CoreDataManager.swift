//
//  CoreDataManager.swift
//  RMS
//
//  Created by Mac Mini on 8/21/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager: NSObject {
    
    static let sharedInstance = CoreDataManager()
    private override init() {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "RMS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Start of EB Claims Transactions
    func clearMasterData() {
        do {
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: MASTER_DATA.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                self.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func saveInMasterDataWith(phoneNumber: String, pin: String, array: [[String: AnyObject]]) {
        _ = array.map{self.createMasterEntityFrom(phoneNumber: phoneNumber, pin: pin, dictionary: $0)}
        do {
            try persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    private func createMasterEntityFrom(phoneNumber: String, pin: String, dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        if let masterEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: MASTER_DATA.self), into: context) as? MASTER_DATA {
            masterEntity.pin = pin
            masterEntity.mobileNumber = phoneNumber
            masterEntity.changePin = dictionary["change_pin"] as? String
            masterEntity.staffID = dictionary["staff_id"] as? String
            masterEntity.clientID = dictionary["client_no"] as? String
            return masterEntity
        }
        return nil
    }
    
    func clearStaffDetails() {
        do {
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: STAFF_DETAILS.self))
            let fetchRequestDependent = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: DEPENDENT_DETAILS.self))
            let fetchRequestPdf = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: PDF.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                let objectsDependent  = try context.fetch(fetchRequestDependent) as? [NSManagedObject]
                _ = objectsDependent.map{$0.map{context.delete($0)}}
                let objectsPdf  = try context.fetch(fetchRequestPdf) as? [NSManagedObject]
                _ = objectsPdf.map{$0.map{context.delete($0)}}
                self.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func saveInStaffDataWith(array: [[[String: AnyObject]]]) {
        for array in array {
            let data = array as [[String:Any]]
            _ = data.map{self.createStaffEntityFrom(dictionary: $0 as [String : AnyObject])}
            do {
                try persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func createStaffEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        if let staffEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: STAFF_DETAILS.self), into: context) as? STAFF_DETAILS {
            staffEntity.client_id = dictionary["client_id"] as? String ?? ""
            staffEntity.staff_id = dictionary["staff_id"] as? String ?? ""
            staffEntity.policy_ref = dictionary["policy_ref"] as? String ?? ""
            staffEntity.member_id = dictionary["member_id"] as? String ?? ""
            staffEntity.member_name = dictionary["member_name"] as? String ?? ""
            staffEntity.relationship = dictionary["relationship"] as? String ?? ""
            staffEntity.dender = dictionary["dender"] as? String ?? ""
            staffEntity.nationality = dictionary["nationality"] as? String ?? ""
            staffEntity.phone = dictionary["phone"] as? String ?? ""
            staffEntity.effective_date = dictionary["effective_date"] as? String ?? ""
            staffEntity.email = dictionary["email"] as? String ?? ""
            if dictionary["dependents"] != nil {
                let dependent = dictionary["dependents"] as! [[String:Any]]
                for dependent in dependent {
                    if let dependentEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: DEPENDENT_DETAILS.self), into: context) as? DEPENDENT_DETAILS {
                        dependentEntity.client_id = dependent["client_id"] as? String ?? ""
                        dependentEntity.staff_id = dependent["staff_id"] as? String ?? ""
                        dependentEntity.policy_ref = dependent["policy_ref"] as? String ?? ""
                        dependentEntity.member_id = dependent["member_id"] as? String ?? ""
                        dependentEntity.member_name = dependent["member_name"] as? String ?? ""
                        dependentEntity.relationship = dependent["relationship"] as? String ?? ""
                        dependentEntity.dender = dependent["dender"] as? String ?? ""
                        dependentEntity.nationality = dependent["nationality"] as? String ?? ""
                        dependentEntity.phone = dependent["phone"] as? String ?? ""
                        dependentEntity.effective_date = dependent["effective_date"] as? String ?? ""
                        dependentEntity.email = dependent["email"] as? String ?? ""
                        staffEntity.addToDependent(_ :dependentEntity)
                    }
                }
            }
            
            if dictionary["pdfs"] != nil {
                let pdf = dictionary["pdfs"] as! [String:Any]
                for (key, _) in pdf {
                    if let pdfEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: PDF.self), into: context) as? PDF {
                        if (key == "member_guide"){
                            pdfEntity.pdf_name = "Member Guide"
                            pdfEntity.pdf_link = pdf["member_guide"] as? String ?? ""
                        } else if (key == "hospital_network"){
                            pdfEntity.pdf_name = "Hospital Network"
                            pdfEntity.pdf_link = pdf["hospital_network"] as? String ?? ""
                        } else if (key == "claim_form"){
                            pdfEntity.pdf_name = "Claim Form"
                            pdfEntity.pdf_link = pdf["claim_form"] as? String ?? ""
                        } else if (key == "pre_approval_form"){
                            pdfEntity.pdf_name = "Pre Approval Form"
                            pdfEntity.pdf_link = pdf["pre_approval_form"] as? String ?? ""
                        }
                    }
                }
            }
            return staffEntity
        }
        return nil
    }
    
    func clearClaimDetails() {
        do {
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CLAIM_DETAILS.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                self.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func saveInClaimDataWith(array: [[[String: AnyObject]]]) {
        for array in array {
            let data = array as [[String:Any]]
            _ = data.map{self.createClaimEntityFrom(dictionary: $0 as [String : AnyObject])}
            do {
                try persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func createClaimEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        if let claimEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: CLAIM_DETAILS.self), into: context) as? CLAIM_DETAILS {
            claimEntity.claim_no = dictionary["claim_no"] as? String ?? ""
            claimEntity.reg_date = dictionary["reg_date"] as? String ?? ""
            claimEntity.member_name = dictionary["member_name"] as? String ?? ""
            claimEntity.staff_name = dictionary["staff_name"] as? String ?? ""
            claimEntity.treatment_date = dictionary["treatment_date"] as? String ?? ""
            claimEntity.status = dictionary["status"] as? String ?? ""
            claimEntity.member_type = dictionary["member_type"] as? String ?? ""
            claimEntity.claimed_mount = dictionary["amount"] as? String ?? ""
            claimEntity.approved_amount = dictionary["payment"] as? String ?? ""
            claimEntity.excess = dictionary["excess"] as? String ?? ""
            claimEntity.disallowance = dictionary["disallowance"] as? String ?? ""
            claimEntity.settled_amount_ro = dictionary["ref_amnt"] as? String ?? ""
            claimEntity.mode_of_payment = dictionary["mode_of_payment"] as? String ?? ""
            claimEntity.cheque_no = dictionary["cheque_no"] as? String ?? ""
            claimEntity.settled_amount = dictionary["cheque_rec_date"] as? String ?? ""
            claimEntity.remarks = dictionary["remarks"] as? String ?? ""
            claimEntity.policy_no = dictionary["policy_no"] as? String ?? ""
            claimEntity.diagnosis = dictionary["diagnosis"] as? String ?? ""
            
            return claimEntity
        }
        return nil
    }
    
    func clearPreApprovalDetails() {
        do {
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: PRE_APPROVALS.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                self.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func saveInPreApprovalDataWith(array: [[[String: AnyObject]]]) {
        for array in array {
            let data = array as [[String:Any]]
            _ = data.map{self.createPreApprovalEntityFrom(dictionary: $0 as [String : AnyObject])}
            do {
                try persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func createPreApprovalEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        if let preApprovalEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: PRE_APPROVALS.self), into: context) as? PRE_APPROVALS {
            preApprovalEntity.memberid = dictionary["memberid"] as? String ?? ""
            preApprovalEntity.patient_name = dictionary["patient_name"] as? String ?? ""
            preApprovalEntity.staff_id = dictionary["staff_id"] as? String ?? ""
            preApprovalEntity.staff_name = dictionary["staff_name"] as? String ?? ""
            preApprovalEntity.pol_ref = dictionary["pol_ref"] as? String ?? ""
            preApprovalEntity.entry_dt = dictionary["entry_dt"] as? String ?? ""
            preApprovalEntity.diagnosis = dictionary["diagnosis"] as? String ?? ""
            preApprovalEntity.place_code = dictionary["place_code"] as? String ?? ""
            preApprovalEntity.hospital_name = dictionary["hospital_name"] as? String ?? ""
            preApprovalEntity.pre_approvalno = dictionary["pre_approvalno"] as? String ?? ""
            preApprovalEntity.pre_approvaldt = dictionary["pre_approvaldt"] as? String ?? ""
            preApprovalEntity.remarks = dictionary["remarks"] as? String ?? ""
            preApprovalEntity.status = dictionary["status"] as? String ?? ""
            
            return preApprovalEntity
        }
        return nil
    }
    // End of EB Claims Transactions
    
    // Start of Monthly Salary Deduction Transaction
    func clearMasterDataSalary() {
        do {
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: MASTER_DATA_SALARY.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                self.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func saveInMasterDataSalaryWith(nationalId: String, pin: String, array: [[String: AnyObject]]) {
        _ = array.map{self.createMasterSalaryEntityFrom(nationalId: nationalId, pin: pin, dictionary: $0)}
        do {
            try persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    private func createMasterSalaryEntityFrom(nationalId: String, pin: String, dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        if let masterEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: MASTER_DATA_SALARY.self), into: context) as? MASTER_DATA_SALARY {
            masterEntity.pin = pin
            masterEntity.nationalID = nationalId
            masterEntity.changePin = dictionary["change_pin"] as? String
            masterEntity.staffID = dictionary["staff_id"] as? String
            masterEntity.clientID = dictionary["client_no"] as? String
            return masterEntity
        }
        return nil
    }
    
    func clearPolicyDetails() {
        do {
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: STAFF_DETAILS_SALARY.self))
            let fetchRequestDependent = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: STAFF_DETAILS_POLICY.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                let objectsDependent  = try context.fetch(fetchRequestDependent) as? [NSManagedObject]
                _ = objectsDependent.map{$0.map{context.delete($0)}}
                self.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func saveInPolicyDataWith(array: [[[String: AnyObject]]]) {
        for array in array {
            let data = array as [[String:Any]]
            _ = data.map{self.createPolicyEntityFrom(dictionary: $0 as [String : AnyObject])}
            do {
                try persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func createPolicyEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        if let staffEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: STAFF_DETAILS_SALARY.self), into: context) as? STAFF_DETAILS_SALARY {
            staffEntity.nationalID = dictionary["national_id"] as? String ?? ""
            staffEntity.staffID = dictionary["staff_id"] as? String ?? ""
            staffEntity.clientID = dictionary["client_no"] as? String ?? ""
            staffEntity.staffName = dictionary["staff_name"] as? String ?? ""
            if let policyEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: STAFF_DETAILS_POLICY.self), into: context) as? STAFF_DETAILS_POLICY {
                policyEntity.nationalID = dictionary["national_id"] as? String ?? ""
                policyEntity.staffID = dictionary["staff_id"] as? String ?? ""
                policyEntity.policyNo = dictionary["policy_no"] as? String ?? ""
                policyEntity.startDate = dictionary["start_date"] as? String ?? ""
                policyEntity.endDate = dictionary["expiry_date"] as? String ?? ""
                return policyEntity
            }
            return staffEntity
        }
        return nil
    }
    
    func clearAccountSummary() {
        do {
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ACCOUNT_SUMMARY.self))
            let fetchRequestDependent = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: POLICY_INSTALLMENT.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                let objectsDependent  = try context.fetch(fetchRequestDependent) as? [NSManagedObject]
                _ = objectsDependent.map{$0.map{context.delete($0)}}
                self.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func saveInAccountSummaryDataWith(array: [[[String: AnyObject]]]) {
        for array in array {
            let data = array as [[String:Any]]
            _ = data.map{self.createAccountSummaryEntityFrom(dictionary: $0 as [String : AnyObject])}
            do {
                try persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func createAccountSummaryEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        if let accountyEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: ACCOUNT_SUMMARY.self), into: context) as? ACCOUNT_SUMMARY {
            accountyEntity.nationalID = dictionary["national_id"] as? String ?? ""
            accountyEntity.staffID = dictionary["staff_id"] as? String ?? ""
            accountyEntity.vehicleNumber = dictionary["vehicle_no"] as? String ?? ""
            accountyEntity.status = dictionary["status"] as? String ?? ""
            accountyEntity.outstandingAmount = (dictionary["outstanding_amount"] as? Float) ?? 00.00
            accountyEntity.totalPremium = dictionary["tot_premium"] as? String ?? ""
            accountyEntity.nextInstallmentAmount = (dictionary["next_installment_amount"] as? Float) ?? 00.00
            accountyEntity.insurer = dictionary["insurrer"] as? String ?? ""
            accountyEntity.startDate = dictionary["policy_start_date"] as? String ?? ""
            accountyEntity.endDate = dictionary["policy_expiry_date"] as? String ?? ""
            accountyEntity.policyNo = dictionary["policy_no"] as? String ?? ""
            accountyEntity.policyYear = dictionary["policy_year"] as? String ?? ""
            if dictionary["installments"] != nil {
                let dependent = dictionary["installments"] as! [[String:Any]]
                for dependent in dependent {
                    let amount = dependent["amount"] as? String ?? ""
                    if (amount != "") {
                        if let dependentEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: POLICY_INSTALLMENT.self), into: context) as? POLICY_INSTALLMENT {
                            dependentEntity.vehicleNumber = dictionary["vehicle_no"] as? String ?? ""
                            dependentEntity.date = dependent["date"] as? String ?? ""
                            dependentEntity.amount = dependent["amount"] as? String ?? ""
                            dependentEntity.status = dependent["status"] as? String ?? ""
                            accountyEntity.addToInstallment(_ :dependentEntity)
                        }
                    }
                }
            }
            return accountyEntity
        }
        return nil
    }
    //End of Monthly Salary Deduction Transaction
    
    //Start of Personal Lines Transaction
    func clearMasterDataLines() {
        do {
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: MASTER_DATA_LINES.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                self.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func saveInMasterDataLinesWith(nationalId: String, pin: String, array: [[String: AnyObject]]) {
        _ = array.map{self.createMasterLinesEntityFrom(nationalId: nationalId, pin: pin, dictionary: $0)}
        do {
            try persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    private func createMasterLinesEntityFrom(nationalId: String, pin: String, dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        if let masterEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: MASTER_DATA_LINES.self), into: context) as? MASTER_DATA_LINES {
            masterEntity.pin = pin
            masterEntity.nationalID = nationalId
            masterEntity.changePin = dictionary["change_pin"] as? String
            masterEntity.staffID = dictionary["staff_id"] as? String
            masterEntity.clientID = dictionary["client_no"] as? String
            return masterEntity
        }
        return nil
    }
    
    func clearPolicyDetailsLines() {
        do {
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: STAFF_DETAILS_LINES.self))
            let fetchRequestDependent = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: STAFF_DETAILS_POLICY_LINES.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                let objectsDependent  = try context.fetch(fetchRequestDependent) as? [NSManagedObject]
                _ = objectsDependent.map{$0.map{context.delete($0)}}
                self.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func saveInPolicyLinesDataWith(array: [[[String: AnyObject]]]) {
        for array in array {
            let data = array as [[String:Any]]
            _ = data.map{self.createPolicyLinesEntityFrom(dictionary: $0 as [String : AnyObject])}
            do {
                try persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func createPolicyLinesEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        if let staffEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: STAFF_DETAILS_LINES.self), into: context) as? STAFF_DETAILS_LINES {
            staffEntity.nationalID = dictionary["national_id"] as? String ?? ""
            staffEntity.staffID = dictionary["staff_id"] as? String ?? ""
            staffEntity.clientID = dictionary["client_no"] as? String ?? ""
            staffEntity.staffName = dictionary["staff_name"] as? String ?? ""
            if let policyEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: STAFF_DETAILS_POLICY_LINES.self), into: context) as? STAFF_DETAILS_POLICY_LINES {
                policyEntity.nationalID = dictionary["national_id"] as? String ?? ""
                policyEntity.staffID = dictionary["staff_id"] as? String ?? ""
                policyEntity.policyNo = dictionary["policy_no"] as? String ?? ""
                policyEntity.startDate = dictionary["start_date"] as? String ?? ""
                policyEntity.endDate = dictionary["expiry_date"] as? String ?? ""
                return policyEntity
            }
            return staffEntity
        }
        return nil
    }
    
    func clearAccountSummaryLines() {
        do {
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: ACCOUNT_SUMMARY_LINES.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                self.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func saveInAccountSummaryLinesDataWith(array: [[[String: AnyObject]]]) {
        for array in array {
            let data = array as [[String:Any]]
            _ = data.map{self.createAccountSummaryLinesEntityFrom(dictionary: $0 as [String : AnyObject])}
            do {
                try persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func createAccountSummaryLinesEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        if let accountyEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: ACCOUNT_SUMMARY_LINES.self), into: context) as? ACCOUNT_SUMMARY_LINES {
            accountyEntity.nationalID = dictionary["national_id"] as? String ?? ""
            accountyEntity.staffID = dictionary["staff_id"] as? String ?? ""
            accountyEntity.vehicleNumber = dictionary["vehicle_no"] as? String ?? ""
            accountyEntity.status = dictionary["status"] as? String ?? ""
            accountyEntity.outstandingAmount = (dictionary["outstanding_amount"] as? Float) ?? 00.00
            accountyEntity.totalPremium = dictionary["tot_premium"] as? String ?? ""
            accountyEntity.nextInstallmentAmount = (dictionary["next_installment_amount"] as? Float) ?? 00.00
            accountyEntity.insurer = dictionary["insurrer"] as? String ?? ""
            accountyEntity.startDate = dictionary["policy_start_date"] as? String ?? ""
            accountyEntity.endDate = dictionary["policy_expiry_date"] as? String ?? ""
            accountyEntity.policyNo = dictionary["policy_no"] as? String ?? ""
            accountyEntity.policyYear = dictionary["policy_year"] as? String ?? ""
            return accountyEntity
        }
        return nil
    }
    //End of Personal Lines Transaction
}


extension CoreDataManager {
    
    func applicationDocumentsDirectory() {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "yo.BlogReaderApp" in the application's documents directory.
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
}
