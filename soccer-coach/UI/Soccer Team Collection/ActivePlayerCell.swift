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
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var player: SoccerPlayer?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        nameLabel.layer.cornerRadius = nameLabel.frame.width / 2
        nameLabel.clipsToBounds = true
        visualEffectView.layer.cornerRadius = nameLabel.frame.width / 2
        visualEffectView.clipsToBounds = true

    }
    
    func configure(with player: SoccerPlayer) {
        self.player = player
        nameLabel.text = player.name
    }
    
}
