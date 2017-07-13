//
//  CustomPreapproval.swift
//  RMS
//
//  Created by Mac Mini on 7/6/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit

class CustomPreapproval : UIViewController {
    let transitioner = CAVTransitioner()
    let constants = Constants();
    var patientId1 = ""
    var patientName1 = ""
    var staffId1 = ""
    var staffName1 = ""
    var policyRef1 = ""
    var entryDate1 = ""
    var diagnosis1 = ""
    var place1 = ""
    var hospitalName1 = ""
    var status1 = ""
    var preapprovalNo1 = ""
    var preApprovalDate1 = ""
    var remarks1 = ""
    
    @IBOutlet weak var patientId: UILabel!
    @IBOutlet weak var patientName: UITextView!
    @IBOutlet weak var staffId: UILabel!
    @IBOutlet weak var staffName: UILabel!
    @IBOutlet weak var policyRef: UILabel!
    @IBOutlet weak var entryDate: UILabel!
    @IBOutlet weak var diagnosis: UILabel!
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var hospitalName: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var preapprovalNo: UILabel!
    @IBOutlet weak var preApprovalDate: UILabel!
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
        patientId?.text = patientId1
        patientName.text = patientName1
        staffId.text = staffId1
        staffName.text = staffName1
        policyRef.text = policyRef1
        entryDate.text = entryDate1
        diagnosis.text = diagnosis1
        place.text = place1
        hospitalName.text = hospitalName1
        status.text = status1
        preapprovalNo.text = preapprovalNo1
        preApprovalDate.text = preApprovalDate1
        remarks.text = remarks1
    }
}
