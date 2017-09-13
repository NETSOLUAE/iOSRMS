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

}

