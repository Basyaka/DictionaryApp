//
//  TableViewCell.swift
//  Dictionary
//
//  Created by Vlad Novik on 6/26/20.
//  Copyright © 2020 Vlad Novik. All rights reserved.
//

import UIKit

class DictionaryViewCell: UITableViewCell {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var transcriptionLabel: UILabel!
    @IBOutlet weak var translateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    

    
}
