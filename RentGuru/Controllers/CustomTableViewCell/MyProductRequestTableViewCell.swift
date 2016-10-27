//
//  MyProductRequestTableViewCell.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/19/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit

class MyProductRequestTableViewCell: UITableViewCell {
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var productName: UILabel!
    @IBOutlet var userName: UILabel!
    @IBOutlet var dateRenge: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
