//
//  TableBenifits.swift
//  RMS
//
//  Created by Mac Mini on 7/4/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

class TableBenifits:UIViewController, IndicatorInfoProvider, UIWebViewDelegate {
    
    var itemInfo: IndicatorInfo = "Table"
    let constants = Constants();
    var webView: UIWebView!
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = UIWebView(frame: UIScreen.main.bounds)
        webView.delegate = self
        view.addSubview(webView)
        
        loadPolicy(actionId: "privacy-policy")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func loadPolicy(actionId: String) -> Void {
        DispatchQueue.main.async(execute: {
            /* Do some heavy work (you are now on a background queue) */
            self.showActivityIndicator(view: self.webView, targetVC: self)
        });
        let POST_PARAMS = "?action_id=" + actionId;
        
        let urlString = constants.BASE_URL + POST_PARAMS;
        
        // Create request with URL
        let url = URL(string: urlString)!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpMethod = "POST"
        
        // Fire you request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Do whatever you would like to
            if (error != nil) {
                print (error?.localizedDescription ?? "URL Error!")
                self.alertDialog(heading: "Alert", message: error?.localizedDescription ?? self.constants.errorMessage)
            } else {
                if let urlContent = data {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: urlContent, options: .allowFragments) as! [String:Any]
                        let status = parsedData["status"] as! String
                        
                        let message = parsedData["message"] as! String
                        
                        if (status == "success"){
                            let data = parsedData["data"] as! [String:Any]
                            let contents = data["contents"] as? String ?? ""
                            self.webView.loadHTMLString(contents, baseURL: nil)
                        } else if (status == "fail") {
                            self.alertDialog (heading: "", message: message);
                            return
                        } else {
                            self.alertDialog (heading: "", message: self.constants.errorMessage);
                            return
                        }
                        
                    } catch {
                        DispatchQueue.main.sync(execute: {
                            /* stop the activity indicator (you are now on the main queue again) */
                            self.hideActivityIndicator(view: self.webView)
                        });
                        print("JSON processessing failed")
                        return
                    }//catch closing bracket
                }// if let closing bracket
                DispatchQueue.main.sync(execute: {
                    /* stop the activity indicator (you are now on the main queue again) */
                    self.hideActivityIndicator(view: self.webView)
                });
            }//else closing bracket
        }// task closing bracket
        task.resume();
    }
    
    
    func alertDialog (heading: String, message: String) {
        OperationQueue.main.addOperation {
            self.hideActivityIndicator(view: self.webView)
            let alertController = UIAlertController(title: heading, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showActivityIndicator(view: UIView, targetVC: UIViewController) {
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: targetVC.view.frame.width/2 - 25, y: targetVC.view.frame.height/2 - 150, width: 50, height: 50))
        activityIndicator.backgroundColor = UIColor.gray
        activityIndicator.layer.cornerRadius = 6
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        activityIndicator.tag = 1
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideActivityIndicator(view: UIView) {
        let activityIndicator = view.viewWithTag(1) as? UIActivityIndicatorView
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}

extension String {
    
    var htmlToAttributedString: NSAttributedString? {
        do {
            let data = self.data(using: String.Encoding.utf8, allowLossyConversion: true)
            if let d = data {
                let str = try NSAttributedString(data: d,
                                                 options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                 documentAttributes: nil)
                return str
            }
        } catch {
        }
        return nil
    }
}