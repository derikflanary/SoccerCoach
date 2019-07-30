//
//  PlayerCollectionViewCell.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/29/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class PlayerCollectionViewCell: UICollectionViewCell, ReusableView {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with player: SoccerPlayer) {
        nameLabel.text = player.name
    }

}
