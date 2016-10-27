//
//  MyRequestTableViewCell.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/19/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit

class MyRequestTableViewCell: UITableViewCell {
    @IBOutlet var ownerName: UILabel!
    @IBOutlet var dateRange: UILabel!
    @IBOutlet var productName: UILabel!
    @IBOutlet var productImageView: UIImageView!
 
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
