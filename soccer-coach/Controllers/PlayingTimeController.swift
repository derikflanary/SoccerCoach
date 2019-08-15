//
//  PlayingTimeController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/26/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct PlayingTimeController {
    
    static var shared = PlayingTimeController()
    
    var context: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
    
    func playingTime(for player: SoccerPlayer, match: Match, teamType: TeamType) -> PlayingTime? {
        switch teamType {
        case .home:
            return match.homePlayingTime?.first(where: { (playingTime) -> Bool in
                return playingTime.player == player && playingTime.isActive
            })
        case .away:
            return match.awayPlayingTime?.first(where: { (playingTime) -> Bool in
                return playingTime.player == player && playingTime.isActive
            })
        }
    }
    
    func playingTimes(for player: SoccerPlayer, match: Match, teamType: TeamType) -> [PlayingTime] {
        switch teamType {
        case .home:
            let playingTimes = match.homePlayingTime?.filter { $0.player == player }.compactMap { $0 } ?? []
            if let playingTime = playingTimes.last {
                playingTime.setCurrentLength(match: match)
            }
            return playingTimes
        case .away:
            let playingTimes = match.awayPlayingTime?.filter { $0.player == player }.compactMap { $0 } ?? []
            if let playingTime = playingTimes.first {
                playingTime.setCurrentLength(match: match)
            }
            return playingTimes
        }
    }
    
    func addPlayingTime(to match: Match, for player: SoccerPlayer, teamType: TeamType, position: Position, halfHasStarted: Bool) {
        guard halfHasStarted else { return }
        guard let context = context else { return }
        let playingTime = PlayingTime(context: context)
        playingTime.player = player
        playingTime.length = 0
        playingTime.half = match.half
        playingTime.isActive = true
        playingTime.positionValue = Int64(position.rawValue)
        switch match.currentHalf {
        case .first:
            playingTime.startTime = match.firstHalfTimeElapsed
        case .second:
            playingTime.startTime = match.secondHalfTimeElapsed
        case .extra:
            playingTime.startTime = match.extraTimeTimeElaspsed
        }
        switch teamType {
        case .home:
            match.addToHomePlayingTime(playingTime)
        case .away:
            match.addToAwayPlayingTime(playingTime)
        }
        print("began: \(playingTime)")
    }
    
    func endPlayingTime(for player: SoccerPlayer, match: Match, teamType: TeamType) {
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType), playingTime.isActive else { return }
        playingTime.isActive = false
        if let half = Half(rawValue: Int(playingTime.half)) {
            switch half {
            case .first:
                playingTime.length = match.firstHalfTimeElapsed - playingTime.startTime
            case .second:
                playingTime.length = match.secondHalfTimeElapsed - playingTime.startTime
            case .extra:
                playingTime.length = match.extraTimeTimeElaspsed - playingTime.startTime
            }
        }
        if playingTime.length < 30 {
            match.removeFromAwayPlayingTime(playingTime)
        }
        print("ended: \(playingTime)")
    }
    
    func addShot(to player: SoccerPlayer, match: Match, teamType: TeamType, rating: Int, onTarget: Bool, isGoal: Bool, description: String? = nil, assistee: SoccerPlayer?) {
        guard let context = context else { return }
        guard let playerPlayingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
        let shot = Shot(context: context)
        shot.half = playerPlayingTime.half
        shot.rating = Int64(rating)
        shot.onTarget = onTarget
        shot.isGoal = isGoal
        shot.shotDescription = description
        if let assistee = assistee, let assisteePlayingTime = playingTime(for: assistee, match: match, teamType: teamType) {
            let assist = Assist(context: context)
            assist.goal = shot
            shot.assist = assist
            assisteePlayingTime.addToAssists(assist)
        }
        guard let half = Half(rawValue: Int(shot.half)) else { return }
        switch half {
        case .first:
            shot.timeStamp = Int64(match.firstHalfTimeElapsed)
        case .second:
            shot.timeStamp = Int64(match.secondHalfTimeElapsed)
        case .extra:
            shot.timeStamp = Int64(match.extraTimeTimeElaspsed)
        }
        playerPlayingTime.addToShots(shot)
        if shot.isGoal {
            switch teamType {
            case .home:
                App.sharedCore.fire(event: HomeGoalScored())
            case .away:
                App.sharedCore.fire(event: AwayGoalScored())
            }
        }
    }
    
    func addTurnover(to player: SoccerPlayer, match: Match, teamType: TeamType, badPass: Bool, badTouch: Bool) {
        guard let context = context else { return }
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
        let turnover = Turnover(context: context)
        turnover.isBadPass = badPass
        turnover.isBadTouch = badTouch
        turnover.half = playingTime.half
        guard let half = Half(rawValue: Int(turnover.half)) else { return }
        switch half {
        case .first:
            turnover.timeStamp = Int64(match.firstHalfTimeElapsed)
        case .second:
            turnover.timeStamp = Int64(match.secondHalfTimeElapsed)
        case .extra:
            turnover.timeStamp = Int64(match.extraTimeTimeElaspsed)
        }
        playingTime.addToTurnovers(turnover)
    }
    

    func addFoul(to player: SoccerPlayer, match: Match, teamType: TeamType, isOffsides: Bool) {
        guard let context = context else { return }
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
        let foul = Foul(context: context)
        foul.half = playingTime.half
        foul.isOffsides = isOffsides
        guard let half = Half(rawValue: Int(foul.half)) else { return }
        switch half {
        case .first:
            foul.timeStamp = Int64(match.firstHalfTimeElapsed)
        case .second:
            foul.timeStamp = Int64(match.secondHalfTimeElapsed)
        case .extra:
            foul.timeStamp = Int64(match.extraTimeTimeElaspsed)
        }
        playingTime.addToFouls(foul)
    }
    
    func addCard(to player: SoccerPlayer, match: Match, teamType: TeamType, cardType: CardType) {
        guard let context = context else { return }
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
        let card = Card(context: context)
        card.half = playingTime.half
        card.type = cardType.rawValue
        guard let half = Half(rawValue: Int(card.half)) else { return }
        switch half {
        case .first:
            card.timeStamp = Int64(match.firstHalfTimeElapsed)
        case .second:
            card.timeStamp = Int64(match.secondHalfTimeElapsed)
        case .extra:
            card.timeStamp = Int64(match.extraTimeTimeElaspsed)
        }
        playingTime.addToCards(card)
    }
    
}
