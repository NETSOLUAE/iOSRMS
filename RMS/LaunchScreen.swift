//
//  LaunchScreen.swift
//  RMS
//
//  Created by Mac Mini on 7/10/17.
//  Copyright © 2017 Netsol. All rights reserved.
//


import UIKit

class LaunchScreen: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.animate(withDuration: 1.0, delay: 0.5, animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 1.5,y: 1.5);
            self.imageView.alpha = 0.0
        }, completion: { (finished: Bool) in
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "MenuController") as UIViewController
            self.present(vc, animated: true, completion: nil)
        })
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
