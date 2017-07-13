//
//  Section.swift
//  RMS
//
//  Created by Mac Mini on 7/10/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation

struct SectionContact {
    var genre: String!
    var movies: [Address]!
    var expanded: Bool!
    
    init(genre: String, movies: [Address], expanded: Bool) {
        self.genre = genre
        self.movies = movies
        self.expanded = expanded
    }
}

struct Address {
    var branch_name: String!
    var telephone: String!
    var email: String!
    var address: NSMutableAttributedString!
    
    init(branch_name: String, address: NSMutableAttributedString, telephone: String, email: String) {
        self.branch_name = branch_name
        self.telephone = telephone
        self.email = email
        self.address = address
    }
}
