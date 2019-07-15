//
//  Match.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/25/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

struct Match {
    
    var date: Date
    var halfLength: Int
    var score: Score
    var homeTeam: Team
    var homeTeamPlayingTimes: [PlayingTime]
    var awayTeam: Team
    var awayTeamPlayingTime: [PlayingTime]
    
}

enum SoccerPosition: String, Codable {
    case g, rcb, lcb, rob, lob, hm, ram, lam, rw, lw, f
}

enum Card: String {
    case red, yellow
}

enum Half: Int {
    case first, second
}
