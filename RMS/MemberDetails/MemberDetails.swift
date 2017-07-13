//
//  MemberDetails.swift
//  RMS
//
//  Created by Mac Mini on 7/1/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import CoreData

//
// MARK: - Section Data Structure
//
struct Section {
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

class MemberDetails: UITableViewController, IndicatorInfoProvider {
    var itemInfo: IndicatorInfo = "Member Details"
    var sections = [Section]()
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "MemberGroup", bundle: Bundle.main)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "MemberGroup")
        tableView.register(UINib(nibName: "MemberChild", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        var dependentsArray = Array<String>()
        var relationArray = Array<String>()
        
        // Initialize the sections array
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
                let memberName = (people.value(forKey: "member_name") ?? "") as! String;
                var dependents  = [DEPENDENT_DETAILS]() // Where Locations = your NSManaged Class
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DEPENDENT_DETAILS")
                do {
                    dependents = try managedContext.fetch(fetchRequest) as! [DEPENDENT_DETAILS]
                    for dependents in dependents {
                        dependentsArray.append(dependents.member_name!)
                        relationArray.append(dependents.relationship!)
                    }
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                sections.append(Section(name: memberName, items: dependentsArray, relationship: relationArray))
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

}
//
// MARK: - View Controller DataSource and Delegate
//
extension MemberDetails {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MemberChild
        cell.name?.text = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        cell.relation?.text = sections[(indexPath as NSIndexPath).section].relationship[(indexPath as NSIndexPath).row]
        
        cell.name?.text = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        cell.relation?.text=sections[(indexPath as NSIndexPath).section].relationship[(indexPath as NSIndexPath).row]
        cell.imageView?.image = UIImage(named: "member_icon")
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[(indexPath as NSIndexPath).section].collapsed! ? 0 : 44.0
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "MemberGroup")
        let header = cell as! MemberGroup
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
