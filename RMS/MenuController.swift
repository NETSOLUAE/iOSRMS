//
//  ViewController.swift
//  RMS
//
//  Created by Mac Mini on 6/28/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

struct currentSelection {
    static var name = String();
}

class MenuController: UIViewController {

    @IBOutlet weak var background: UIView!
    override func viewDidLoad() {
        background.backgroundColor = UIColor(patternImage: UIImage(named: "background-1")!)
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        currentSelection.name = segue.identifier!
    }

    @IBAction func navigateToAggregator(_ sender: Any) {
        let aggregatorLink = "iOSDevTips://"
        let aggregatorUrl = NSURL(string: aggregatorLink)
        
        if UIApplication.shared.canOpenURL(aggregatorUrl! as URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(aggregatorUrl! as URL, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(aggregatorUrl! as URL)
            }
        } else {
            let alertController = UIAlertController(title: "", message: "Coming Soon!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))
            self.present(alertController, animated: true, completion: nil)
            
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(NSURL(string: "http://instagram.com/")! as URL, options: [:], completionHandler: nil)
//            }
//            else {
//                //redirect to safari because the user doesn't have Instagram
//                UIApplication.shared.openURL(NSURL(string: "http://instagram.com/")! as URL)
//            }
        }
    }
}

