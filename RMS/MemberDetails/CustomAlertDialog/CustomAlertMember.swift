//
//  CustomAlertMember.swift
//  RMS
//
//  Created by Mac Mini on 9/12/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit

class CustomAlertMember : UIViewController {
    let transitioner = CAVTransitioner()
    let constants = Constants();
    var policy = ""
    var name = ""
    var relation = ""
    var gender = ""
    var nationality = ""
    var mobile = ""
    var email = ""
    
    @IBOutlet weak var policyNo: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var relationLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.transitioner
    }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    @IBAction func doClose(_ sender:Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setClaimDetails()
    }
    
    func setClaimDetails() {
        policyNo?.text = policy
        nameLabel.text = name
        relationLabel.text = relation
        genderLabel.text = gender
        nationalityLabel.text = nationality
        mobileLabel.text = mobile
        emailLabel.text = email
    }
}
