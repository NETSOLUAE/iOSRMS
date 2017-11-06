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
    let webserviceManager = WebserviceManager();
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView  = UIWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-150))
        webView.delegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        view.addSubview(webView)
        
        self.webView.loadHTMLString(PolicyDetailsText.policyText, baseURL: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
