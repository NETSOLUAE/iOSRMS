//
//  FAQController.swift
//  RMS
//
//  Created by Mac Mini on 10/10/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

class FAQController: UIViewController {
    
    let constants = Constants();
    let webserviceManager = WebserviceManager();
    var section = [SectionFAQ]()
    var selectedIndex = -1
    var MyObservationContext = 0
    var observing = false
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        background.backgroundColor = UIColor(patternImage: UIImage(named: "background-1")!)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 220
        self.showActivityIndicator(view: self.view, targetVC: self)
        self.faqInfo(actionId: "faqs")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func faqInfo(actionId: String) -> Void {
        
        let urlString = constants.BASE_URL + "?action_id=" + actionId;
        
        // Create request with URL
        let url = URL(string: urlString)!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"
        
        // Fire you request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Do whatever you would like to
            if (error != nil) {
                print (error?.localizedDescription ?? "URL Error!")
            } else {
                if let urlContent = data {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: urlContent, options: .allowFragments) as! [String:Any]
                        let status = parsedData["status"] as! String
                        
                        if (status == "success"){
                            let data = parsedData["data"] as! [[String:Any]]
                            for data in data {
                                var answersArray = [Answers]()
                                let questions = data["title"] as? String ?? ""
                                let answers = data["description"] as? String ?? ""
                                
                                let newlineChars = NSCharacterSet.newlines
                                let lineArray = answers.components(separatedBy: newlineChars).filter{!$0.isEmpty}
                                let brCount = answers.components(separatedBy: "</b>").count
                                let pCount = answers.components(separatedBy: "</p>").count
                                let noOfLines = lineArray.count + brCount + pCount
                                answersArray.append(Answers(answers: answers, linesCount: noOfLines))
                                self.section.append(SectionFAQ(question: questions, answers: answersArray, expanded: false))
                            }
                        } else if (status == "fail") {
                            self.alertDialog (heading: "", message: self.constants.errorMessage);
                            return
                        } else {
                            self.alertDialog (heading: "", message: self.constants.errorMessage);
                            return
                        }
                        DispatchQueue.main.sync(execute: {
                            /* stop the activity indicator (you are now on the main queue again) */
                            self.tableView.reloadData()
                            self.hideActivityIndicator(view: self.view)
                        });
                    } catch {
                        DispatchQueue.main.sync(execute: {
                            /* stop the activity indicator (you are now on the main queue again) */
                            self.hideActivityIndicator(view: self.view)
                        });
                        print("JSON processessing failed")
                        return
                    }//catch closing bracket
                }// if let closing bracket
            }//else closing bracket
        }// task closing bracket
        task.resume();
    }
    
    func alertDialog (heading: String, message: String) {
        OperationQueue.main.addOperation {
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
        targetVC.view.addSubview(activityIndicator)
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

extension FAQController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
}

extension FAQController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section1: Int) -> Int {
        return section[section1].answers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (section[indexPath.section].expanded && selectedIndex == indexPath.section) {
            return UITableViewAutomaticDimension
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section1: Int) -> UIView? {
        let header = ExpandableHeaderViewFAQ()
        header.customInit(title: section[section1].question, section: section1, delegate: self)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "faqCall", for: indexPath) as! FAQ
        cell.backgroundColor = .clear
        var answers = self.section[indexPath.section].answers[indexPath.row].answers
        answers = answers?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        cell.answers.preferredMaxLayoutWidth = 404
        
        let yourOtherAttributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont.systemFont(ofSize: 25)]
        
        let partOne = answers?.htmlToAttributedString
        let partTwo = NSMutableAttributedString(string: "\n", attributes: yourOtherAttributes)
        
        let combination = NSMutableAttributedString()
        
        combination.append(partOne!)
        combination.append(partTwo)
        
        cell.answers.attributedText = combination
        
        return cell
    }
    
}

extension FAQController: ExpandableHeaderViewFAQDelegate {
    
    func toggleSection(header: ExpandableHeaderViewFAQ, section section1: Int) {
        if (!section[section1].expanded && selectedIndex != section1) {
            section[section1].expanded = !section[section1].expanded
        } else if (section[section1].expanded && selectedIndex == section1) {
            section[section1].expanded = !section[section1].expanded
        } else if (!section[section1].expanded && selectedIndex == section1) {
            section[section1].expanded = !section[section1].expanded
        }
        selectedIndex = section1
        
        
        tableView.beginUpdates()
        for i in 0 ..< section[section1].answers.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section1)], with: .automatic)
        }
        tableView.endUpdates()
    }
}
