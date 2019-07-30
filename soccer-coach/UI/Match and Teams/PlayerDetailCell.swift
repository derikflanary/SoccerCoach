//
//  PlayerDetailCell.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/30/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class PlayerDetailCell: UITableViewCell, ReusableView {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    
    func configure(with playerStats: PlayerMatchStats) {
        nameLabel.text = playerStats.player.name
        playerStats.goals.forEach { _ in
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            label.text = "⚽️"
            stackView.addArrangedSubview(label)
        }
        for card in playerStats.cards {
            let image = UIImage(systemName: "rectangle.fill")
            let tintColor: UIColor = card.cardType == .yellow ? UIColor.systemYellow : UIColor.systemRed
            let imageView = UIImageView(image: image)
            imageView.tintColor = tintColor
            stackView.addArrangedSubview(imageView)
        }
        
    }

}
