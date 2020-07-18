//
//  CategoryViewCell.swift
//  Dictionary
//
//  Created by Vlad Novik on 7/7/20.
//  Copyright © 2020 Vlad Novik. All rights reserved.
//

import UIKit

class CategoryViewCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
