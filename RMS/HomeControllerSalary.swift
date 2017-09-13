//
//  HomeControllerSalary.swift
//  RMS
//
//  Created by Mac Mini on 8/22/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HomeControllerSalary: ButtonBarPagerTabStripViewControllerSalary {
    
    var isViewDidLaod = false
    let constants = Constants();
    let sharedInstance = CoreDataManager.sharedInstance;
    let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
    
    @IBAction func profileMenu(_ sender: Any) {
        self.slideMenuController()?.openLeft()
    }
    @IBAction func logout(_ sender: Any) {
        alertDialog(heading: "",message: "Do you really want to logout?")
    }
    let redColor = UIColor(red: 221/255.0, green: 0/255.0, blue: 19/255.0, alpha: 1.0)
    let unselectedIconColor = UIColor(red: 73/255.0, green: 8/255.0, blue: 10/255.0, alpha: 1.0)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: "ButtonBarSalary", bundle: Bundle(for: ButtonBarViewCellSalary.self), width: { _ in
            return 55.0
        })
    }
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = redColor
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0)
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .white
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        isHomeViewDidLoad = true
        
        changeCurrentIndexProgressive = {(oldCell: ButtonBarViewCellSalary?, newCell: ButtonBarViewCellSalary?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.imageView.tintColor = .white
            newCell?.imageView.tintColor = .white
        }
        isViewDidLaod = true
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (isViewDidLaod){
            isViewDidLaod = false
            var results : [MASTER_DATA_SALARY]
            let studentUniversityFetchRequest: NSFetchRequest<MASTER_DATA_SALARY>  = MASTER_DATA_SALARY.fetchRequest()
            studentUniversityFetchRequest.returnsObjectsAsFaults = false
            do {
                results = try self.managedContext.fetch(studentUniversityFetchRequest)
                let changePin = results.first!.changePin ?? ""
                if (changePin != "" && changePin == "Yes"){
                    self.resetPinAlert()
                    return
                }
            } catch let error as NSError {
                print ("Could not fetch \(error), \(error.userInfo)")
            }
        }
        
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.addLeftGestures()
        
        super.viewWillAppear(animated)
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = PolicyDetails(itemInfo: IndicatorInfo(title: "Policy Details", image: UIImage(named: "PolicyDetails"), highlightedImage: UIImage(named: "policy-selected")))
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let child_2: UIViewController = storyboard.instantiateViewController(withIdentifier: "AccountSummary") as UIViewController
        let child_3 = PostComments(itemInfo: IndicatorInfo(title: "Post Comments", image: UIImage(named: "post_comments"), highlightedImage: UIImage(named: "post-selected")))
        return [child_1, child_2, child_3]
    }
    
    func alertDialog (heading: String, message: String) {
        OperationQueue.main.addOperation {
            LoadingIndicatorView.hide()
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "LoginController") as UIViewController
                self.present(vc, animated: true, completion: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction!) in
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func resetPinAlert () {
        OperationQueue.main.addOperation {
            let vc = CustomAlertViewController()
            self.present(vc, animated: true)
        }
    }
    
    public func callLoginController () {
        OperationQueue.main.addOperation {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "LoginController") as UIViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension HomeControllerSalary : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
    }
    
    func leftDidOpen() {
    }
    
    func leftWillClose() {
    }
    
    func leftDidClose() {
        let menuItem = self.slideMenuController()?.menuItem
        if (menuItem == "resetpin") {
            resetPinAlert ()
        } else if (menuItem == "logout") {
            alertDialog(heading: "", message: "Do you really want to logout?")
        }
    }
    
    func rightWillOpen() {
    }
    
    func rightDidOpen() {
    }
    
    func rightWillClose() {
    }
    
    func rightDidClose() {
    }
}
