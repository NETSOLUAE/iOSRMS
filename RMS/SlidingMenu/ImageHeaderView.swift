//
//  ImageHeaderView.swift
//  RMS
//
//  Created by Mac Mini on 7/4/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ImageHeaderView : UIView {
    
    @IBOutlet weak var phonenumber: UILabel!
    @IBOutlet weak var name: UILabel!
    let sharedInstance = CoreDataManager.sharedInstance;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(red: 221/255.0, green: 0/255.0, blue: 19/255.0, alpha: 1.0)
        
        if (currentSelection.name == "ebclaims") {
            let managedContext =
                sharedInstance.persistentContainer.viewContext
            
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS")
            do {
                let people = try managedContext.fetch(fetchRequest)
                for people in people {
                    let mobileNumber = (people.value(forKey: "phone") ?? "") as! String;
                    let staffname = (people.value(forKey: "member_name") ?? "") as! String;
                    self.phonenumber.text = mobileNumber;
                    self.name.text = staffname;
                    return
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
        } else if (currentSelection.name == "salary") {
            
            let managedContext =
                sharedInstance.persistentContainer.viewContext
            
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "STAFF_DETAILS_SALARY")
            do {
                let people = try managedContext.fetch(fetchRequest)
                for people in people {
                    let mobileNumber = (people.value(forKey: "nationalID") ?? "") as! String;
                    let staffname = (people.value(forKey: "staffName") ?? "") as! String;
                    self.phonenumber.text = mobileNumber;
                    self.name.text = staffname;
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
                    let mobileNumber = (people.value(forKey: "nationalID") ?? "") as! String;
                    let staffname = (people.value(forKey: "staffName") ?? "") as! String;
                    self.phonenumber.text = mobileNumber;
                    self.name.text = staffname;
                    return
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
}

