//
//  ItemViewCell.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/23/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//

import UIKit

class ToEatCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var toEatImageView: UIImageView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

