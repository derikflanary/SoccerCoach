//
//  MatchStats.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/30/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

struct MatchStats {
    
    var homePlayingTime = [PlayingTime]()
    var awayPlayingTime = [PlayingTime]()
    
    var homeTotalShots: Int {
        return homePlayingTime.compactMap { $0.shots }.count
    }
    var awayTotalShots: Int {
        return awayPlayingTime.compactMap { $0.shots }.count
    }
    var homeShotsOnTarget: Int {
        let shots = homePlayingTime.compactMap { $0.shots }.flatMap { $0 }
        return shots.filter { $0.onTarget }.count
    }
    var awayShotsOnTarget: Int {
        let shots = awayPlayingTime.compactMap { $0.shots }.flatMap { $0 }
        return shots.filter { $0.onTarget }.count
    }
    var homeShotsOffTarget: Int {
        let shots = homePlayingTime.compactMap { $0.shots }.flatMap { $0 }
        return shots.filter { !$0.onTarget }.count
    }
    var awayShotsOffTarget: Int {
        let shots = awayPlayingTime.compactMap { $0.shots }.flatMap { $0 }
        return shots.filter { !$0.onTarget }.count
    }
    var homeAverageShotQuality: Int {
        let shots = homePlayingTime.compactMap { $0.shots }.flatMap { $0 }
        return shots.map { Int($0.rating) }.reduce(0, +) / shots.count
    }
    var awayAverageShotQuality: Int {
        let shots = awayPlayingTime.compactMap { $0.shots }.flatMap { $0 }
        return shots.map { Int($0.rating) }.reduce(0, +) / shots.count
    }
    var homeAssistsTotal: Int {
        return homePlayingTime.compactMap { $0.assists }.flatMap { $0 }.count
    }
    var awayAssistsTotal: Int {
        return awayPlayingTime.compactMap { $0.assists }.flatMap { $0 }.count
    }
    var homeFoulsTotal: Int {
        return homePlayingTime.compactMap { $0.fouls }.flatMap { $0 }.count
    }
    var awayFoulsTotal: Int {
        return awayPlayingTime.compactMap { $0.fouls }.flatMap { $0 }.count
    }
    var homeYellowCardsTotal: Int {
        return homePlayingTime.compactMap { $0.cards }.flatMap { $0 }.filter { $0.cardType == .yellow }.count
    }
    var awayYellowCardsTotal: Int {
        return awayPlayingTime.compactMap { $0.cards }.flatMap { $0 }.filter { $0.cardType == .yellow }.count
    }
    var homeRedCardsTotal: Int {
        return homePlayingTime.compactMap { $0.cards }.flatMap { $0 }.filter { $0.cardType == .red }.count
    }
    var awayRedCardsTotal: Int {
        return awayPlayingTime.compactMap { $0.cards }.flatMap { $0 }.filter { $0.cardType == .red }.count
    }

    init(match: Match?) {
        guard let homePlayingTimeSet = match?.homePlayingTime, let awayPlayingTimeSet = match?.awayPlayingTime else { return }
        self.homePlayingTime = Array(homePlayingTimeSet)
        self.awayPlayingTime = Array(awayPlayingTimeSet)
    }
    
}

struct PlayerMatchStats {
    
    let player: SoccerPlayer
    let playingTimes: [PlayingTime]
    let match: Match
    
    var minutesPlayed: Int {
        return playingTimes.map { $0.length }.reduce(0, +)
    }
    var positions: [Position] {
        return Array(Set(playingTimes.compactMap { $0.position } ))
    }
    var goals: [Shot] {
        return shots.filter { $0.isGoal }
    }
    var shots: [Shot] {
        return playingTimes.compactMap { $0.shots }.flatMap { $0 }
    }
    var shotsOnTarget: [Shot] {
        return shots.filter { $0.onTarget }
    }
    var shotsOffTarget: [Shot] {
        return shots.filter { !$0.onTarget }
    }
    var averageShotRating: Int {
        guard shots.count > 0 else { return 0 }
        return shots.map { Int($0.rating) }.reduce(0, +) / shots.count
    }
    var assists: [Assist] {
        return playingTimes.compactMap { $0.assists }.flatMap { $0 }
    }
    var fouls: [Foul] {
        return playingTimes.compactMap { $0.fouls }.flatMap { $0 }
    }
    var cards: [Card] {
        return playingTimes.compactMap { $0.cards }.flatMap { $0 }
    }
    var turnovers: [Turnover] {
        return playingTimes.compactMap { $0.turnovers }.flatMap { $0 }
    }
    var badPasses: [Turnover] {
        return turnovers.filter { $0.isBadPass }
    }
    var badTouches: [Turnover] {
        return turnovers.filter { $0.isBadTouch }
    }
    var saves: [Save] {
        return playingTimes.compactMap { $0.saves }.flatMap { $0 }
    }
    
}
