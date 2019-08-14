//
//  Keys.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/25/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

enum Keys {
    
    static var savedFillerPlayers: String { return #function }
    static var fillerPlayerName = "🏃🏻‍♀️"
    static var drawing: String { return #function }
    
    enum Entity {
        static var soccerPlayer = "SoccerPlayer"
        static var team = "Team"
        static var playingTime = "PlayingTime"
        static var match = "Match"
        static var shot = "Shot"
        static var assist = "Assist"
        static var foul = "Foul"
        static var card = "Card"
        static var score = "Score"
    }
}
