//
//  PlayerDetails.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/21/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class PlayerDetails: UIViewController {
    
    var player: SoccerPlayer?
    init?(coder: NSCoder, player: SoccerPlayer) {
        self.player = player
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
   
}
