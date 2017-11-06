//
//  ExpandableHeaderViewFAQ.swift
//  RMS
//
//  Created by Mac Mini on 10/10/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit

struct SectionFAQ {
    var question: String!
    var answers: [Answers]
    var expanded: Bool!
    
    init(question: String, answers: [Answers], expanded: Bool) {
        self.question = question
        self.answers = answers
        self.expanded = expanded
    }
}

struct Answers {
    var answers: String!
    var linesCount: Int!
    
    init(answers: String, linesCount: Int) {
        self.answers = answers
        self.linesCount = linesCount
    }
}


protocol ExpandableHeaderViewFAQDelegate {
    func toggleSection(header: ExpandableHeaderViewFAQ, section: Int)
}

class ExpandableHeaderViewFAQ: UITableViewHeaderFooterView {
    var delegate: ExpandableHeaderViewFAQDelegate?
    var section: Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderViewFAQ
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    func customInit(title: String, section: Int, delegate: ExpandableHeaderViewFAQDelegate) {
        self.textLabel?.text = title
        self.section = section
        self.delegate = delegate
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.textColor = UIColor.black
        self.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        contentView.backgroundColor = UIColor.white
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
