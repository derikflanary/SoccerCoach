//
//  Match.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/25/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

struct Match {
    
    var halfLength: Int
    var score: Score
    var homeTeam: Team
    var homeTeamPlayingTimes: [PlayingTime]
    var awayTeam: Team
    var awayTeamPlayingTime: [PlayingTime]
    
}

struct Score {
    
    var home: Int
    var away: Int
    
}

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

protocol TimeStampable {
    var timeStamp: Int { get set }
    var half: Int { get set }
}


struct Assist: TimeStampable {
    var timeStamp: Int
    var half: Int
}

struct Shot: TimeStampable {
    let onTarget: Bool
    let isGoal: Bool
    var timeStamp: Int
    var half: Int
}

struct Foul: TimeStampable {
    var timeStamp: Int
    var half: Int
}

enum SoccerPosition: String {
    case g, rcb, lcb, rob, lob, hm, ram, lam, rw, lw, f
}

struct Team {
    
    let name: String
    var players: [SoccerPlayer]
    
}

enum Card: String {
    case red, yellow
}

enum Half: Int {
    case first, second
}
