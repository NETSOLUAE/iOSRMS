//
//  PDF+CoreDataProperties.swift
//  RMS
//
//  Created by Mac Mini on 8/24/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import CoreData


extension PDF {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PDF> {
        return NSFetchRequest<PDF>(entityName: "PDF")
    }

    @NSManaged public var pdf_link: String?
    @NSManaged public var pdf_name: String?

}
