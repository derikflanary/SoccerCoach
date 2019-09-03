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
    @IBOutlet var minutesPlayedLabel: UILabel!
    
    var arrangedViews = [UIView]()
    
    func configure(with playerStats: PlayerMatchStats) {
        arrangedViews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        nameLabel.text = playerStats.player.name
        if playerStats.minutesPlayed > 0 {
            minutesPlayedLabel.text = "\(playerStats.minutesPlayed) minutes"
        } else if playerStats.minutesPlayed < 0 || !playerStats.playingTimes.isEmpty {
            minutesPlayedLabel.text = "Played"
        } else {
            minutesPlayedLabel.text = "DNP"
        }
        playerStats.goals.forEach { goal in
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            guard let half = Half(rawValue: Int(goal.half)) else { return }
            let minute = Int(goal.timeStamp).minutes.minute(halfLength: 40, half: half)
            label.text = "⚽️ \(minute) "
            label.font = UIFont.systemFont(ofSize: 13)
            label.textAlignment = .right
            stackView.addArrangedSubview(label)
            arrangedViews.append(label)
        }
        playerStats.assists.forEach { assist in
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            guard let half = Half(rawValue: Int(assist.goal!.half)) else { return }
            let minute = Int(assist.goal!.timeStamp).minutes.minute(halfLength: 40, half: half)
            label.text = "🙋‍♂️ \(minute) "
            label.textAlignment = .right
            label.font = UIFont.systemFont(ofSize: 13)
            stackView.addArrangedSubview(label)
            arrangedViews.append(label)
        }
        for card in playerStats.cards {
            let image = UIImage(systemName: "rectangle.fill")
            let tintColor: UIColor = card.cardType == .yellow ? UIColor.systemYellow : UIColor.systemRed
            let imageView = UIImageView(image: image)
            imageView.tintColor = tintColor
            stackView.addArrangedSubview(imageView)
            arrangedViews.append(imageView)
        }
        
    }

}
