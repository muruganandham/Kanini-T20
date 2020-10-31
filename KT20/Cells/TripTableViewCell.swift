//
//  TripTableViewCell.swift
//  KT20
//
//  Created by Muruganandham on 31/10/20.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sourceIcon: UIImageView!
    @IBOutlet weak var destIcon: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var destLabel: UILabel!
    @IBOutlet weak var sourceTimeLabel: UILabel!
    @IBOutlet weak var destTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
