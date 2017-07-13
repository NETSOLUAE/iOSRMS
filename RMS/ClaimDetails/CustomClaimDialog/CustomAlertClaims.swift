//
//  CustomAlertClaims.swift
//  RMS
//
//  Created by Mac Mini on 7/6/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit

class CustomAlertClaims : UIViewController {
    let transitioner = CAVTransitioner()
    let constants = Constants();
    var policy = ""
    var claimNo1 = ""
    var diagnosis1 = ""
    var treatmentDate1 = ""
    var status1 = ""
    var claimedAmount1 = ""
    var approvedAmount1 = ""
    var excess1 = ""
    var disallo1 = ""
    var settledRO1 = ""
    var modeOfPayment1 = ""
    var chequeNo1 = ""
    var settled1 = ""
    var remarks1 = ""
    
    @IBOutlet weak var policyNo: UILabel!
    @IBOutlet weak var claimNo: UILabel!
    @IBOutlet weak var diagnosis: UILabel!
    @IBOutlet weak var treatmentDate: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var claimedAmount: UILabel!
    @IBOutlet weak var approvedAmount: UILabel!
    @IBOutlet weak var excess: UILabel!
    @IBOutlet weak var disallo: UILabel!
    @IBOutlet weak var settledRO: UILabel!
    @IBOutlet weak var modeOfPayment: UILabel!
    @IBOutlet weak var chequeNo: UILabel!
    @IBOutlet weak var settled: UILabel!
    @IBOutlet weak var remarks: UITextView!
    
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
        claimNo.text = claimNo1
        diagnosis.text = diagnosis1
        treatmentDate.text = treatmentDate1
        status.text = status1
        claimedAmount.text = claimedAmount1
        approvedAmount.text = approvedAmount1
        excess.text = excess1
        disallo.text = disallo1
        settledRO.text = settledRO1
        modeOfPayment.text = modeOfPayment1
        chequeNo.text = chequeNo1
        settled.text = settled1
        remarks.text = remarks1
    }
}
