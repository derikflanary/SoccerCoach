//
//  PlayingTime.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/14/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

struct PlayingTime {
    
    let player: SoccerPlayer
    let position: SoccerPosition
    var lenght: TimeInterval
    var shots = [Shot]()
    var assists = [Assist]()
    var fouls = [Foul]()
    var cards = [Card]()
    
    var goals: Int {
        return shots.map { $0.isGoal }.count
    }
    
}
