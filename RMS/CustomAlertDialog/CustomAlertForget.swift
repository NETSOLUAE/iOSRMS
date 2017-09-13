//
//  CustomAlertForget.swift
//  RMS
//
//  Created by Mac Mini on 9/13/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import CoreData

class CustomAlertForget : UIViewController, UITextFieldDelegate {
    var isEB = false;
    let transitioner = CAVTransitioner()
    let constants = Constants();
    let sharedInstance = CoreDataManager.sharedInstance;
    let webserviceManager = WebserviceManager();
    let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.transitioner
    }
    @IBOutlet weak var nationalId: UITextField!
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    @IBAction func doDismiss(_ sender:Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nationalId.delegate = self;
        
        hideKeyboard()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func resetPin(_ sender: Any) {
        self.nationalId.resignFirstResponder()
        let nationaID = self.nationalId.text ?? ""
        if (nationaID == "") {
            self.alertDialog1 (heading: "Alert", message: "Please Enter your NationalID");
        } else {
            LoadingIndicatorView.show("Verifying...")
            var results : [MASTER_DATA]
            let masterDataFetchRequest: NSFetchRequest<MASTER_DATA>  = MASTER_DATA.fetchRequest()
            masterDataFetchRequest.returnsObjectsAsFaults = false
            do {
                results = try managedContext.fetch(masterDataFetchRequest)
                if (results.count > 0) {
                    let mobileNumber = results.first!.mobileNumber ?? ""
                    let staffID = results.first!.staffID ?? ""
                    let clientID = results.first!.clientID ?? ""
                    self.sendSms(params: "\(constants.BASE_URL)?action_id=reset_pin_new&mobile_no=\(mobileNumber)&staff_id=\(staffID)&client_no=\(clientID)&national_id=\(nationaID)")
                }
            } catch let error as NSError {
                print ("Could not fetch \(error), \(error.userInfo)")
            }
        }
    }
    
    func sendSms(params: String) -> Void {
        LoadingIndicatorView.show("Sending SMS....")
        self.webserviceManager.login(type: "single", endPoint: params) { (result) in
            switch result {
            case .SuccessSingle( _, let message):
                LoadingIndicatorView.hideInMain()
                self.alertDialog1 (heading: "", message: message);
            case .Error(let message):
                LoadingIndicatorView.hideInMain()
                self.alertDialog1 (heading: "", message: message);
            default:
                LoadingIndicatorView.hideInMain()
            }
        }
    }
    
    func alertDialog1 (heading: String, message: String) {
//        let appDelegate = UIApplication.shared.delegate
        OperationQueue.main.addOperation {
            LoadingIndicatorView.hide()
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.presentingViewController?.dismiss(animated: true)
//                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "LoginController") as UIViewController
//                (appDelegate?.window??.rootViewController)?.present(vc, animated: true, completion: nil)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height + 100, width: 280, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.systemFont(ofSize: 12)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
        
    }
}
