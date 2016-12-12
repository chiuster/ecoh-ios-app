//
//  RatingCell.swift
//  ecoh
//
//  Created by Ryan Chiu on 5/29/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import UIKit

class RatingCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
