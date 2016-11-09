//
//  ExpandableCategoriesTableViewCell.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/8/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit

class ExpandableCategoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var catName: UILabel!
    @IBOutlet weak var expandableSign: UILabel!
    @IBOutlet weak var separator: UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
