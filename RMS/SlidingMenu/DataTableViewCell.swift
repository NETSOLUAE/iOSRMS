//
//  DataTableViewCell.swift
//  RMS
//
//  Created by Mac Mini on 7/5/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit

struct DataTableViewCellData {
    
    init(imageUrl: String, text: String) {
        self.imageUrl = imageUrl
        self.text = text
    }
    var imageUrl: String
    var text: String
}

class DataTableViewCell : BaseTableViewCell {
    
    @IBOutlet weak var dataImage: UIImageView!
    @IBOutlet weak var dataText: UILabel!
    
    override func awakeFromNib() {
        self.dataText?.font = UIFont.boldSystemFont(ofSize: 13)
        self.dataText?.textColor = .black
    }
    
    override class func height() -> CGFloat {
        return 80
    }
    
    override func setData(_ data: Any?,_ image: Any?) {
        if let data = data as? DataTableViewCellData {
            self.dataImage.image = image as? UIImage
            self.dataText.text = data.text
        }
    }
}
