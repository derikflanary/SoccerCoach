//
//  ActivePlayerCell.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class ActivePlayerCell: UICollectionViewCell, ReusableView {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with player: SoccerPlayer) {
        nameLabel.text = player.name
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        nameLabel.layer.cornerRadius = 8
        nameLabel.clipsToBounds = true
    }

}
