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
    
    var player: SoccerPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let interaction = UIContextMenuInteraction(delegate: self)
//        contentView.addInteraction(interaction)
    }
    
    func configure(with player: SoccerPlayer) {
        self.player = player
        nameLabel.text = player.name
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        nameLabel.layer.cornerRadius = 8
        nameLabel.clipsToBounds = true
    }

}

extension ActivePlayerCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.configuredMenu()
        })
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWith configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return UITargetedPreview(view: nameLabel)
    }
    
    func configuredMenu() -> UIMenu {
        let goal = UIAction(__title: "Goal", image: UIImage(systemName: "plus.circle.fill"), options: []) { action in
        }
        
        let shotOnTarget = UIAction(__title: "Shot on Target", image: UIImage(systemName: "xmark.circle.fill"), options: []) { action in
        }
        
        let shotOffTarget = UIAction(__title: "Shot off Target", image: UIImage(systemName: "xmark.circle"), options: []) { action in
        }
        
        let save = UIAction(__title: "Save", image: UIImage(systemName: "hand.raised"), options: []) { action in
        }
        
        let yellowCard = UIAction(__title: "Yellow Card", image: UIImage(systemName: "square"), options: []) { action in
        }
        
        let redCard = UIAction(__title: "Red Card", image: UIImage(systemName: "square.fill"), options: []) { action in
        }
        
        let cancel = UIAction(__title: "Cancel", image: nil, options: []) { action in
        }
        let children = player?.currentPosition == .g ? [goal, shotOnTarget, shotOffTarget, yellowCard, redCard, save, cancel] : [goal, shotOnTarget, shotOffTarget, yellowCard, redCard, cancel]
        return UIMenu(__title: "", image: nil, identifier: nil, children: [goal, shotOnTarget, shotOffTarget, yellowCard, redCard, cancel])
    }
    
    
    
}
