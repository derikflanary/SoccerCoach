//
//  Match.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/25/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

class Match: NSObject{
    
    var id = UUID()
    var date = Date()
    var halfLength: Int = 40
    var score = Score()
    var homeTeam: Team
    var homeTeamPlayingTimes = [PlayingTime]()
    var awayTeam: Team
    var awayTeamPlayingTime = [PlayingTime]()
    
    init(homeTeam: Team, awayTeam: Team, halfLength: Int = 40) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.halfLength = halfLength
    }
    
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
