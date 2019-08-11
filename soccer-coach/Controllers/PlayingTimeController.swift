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
    
    func addPlayingTime(to match: Match, for player: SoccerPlayer, teamType: TeamType, position: Position) {
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
        print(playingTime)
    }
    
    func endPlayingTime(for player: SoccerPlayer, match: Match, teamType: TeamType) {
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
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
    }
    
    func addAssist(to player: SoccerPlayer, match: Match, teamType: TeamType) {
        guard let context = context else { return }
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
        let assist = Assist(context: context)
        assist.half = playingTime.half
        guard let half = Half(rawValue: Int(assist.half)) else { return }
        switch half {
        case .first:
            assist.timeStamp = Int64(match.firstHalfTimeElapsed)
        case .second:
            assist.timeStamp = Int64(match.secondHalfTimeElapsed)
        case .extra:
            assist.timeStamp = Int64(match.extraTimeTimeElaspsed)
        }
        playingTime.addToAssists(assist)
    }
    
    func addShot(to player: SoccerPlayer, match: Match, teamType: TeamType, rating: Int, onTarget: Bool, isGoal: Bool, description: String? = nil, assistee: SoccerPlayer?) {
        guard let context = context else { return }
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
        let shot = Shot(context: context)
        shot.half = playingTime.half
        shot.rating = Int64(rating)
        shot.onTarget = onTarget
        shot.isGoal = isGoal
        shot.shotDescription = description
        guard let half = Half(rawValue: Int(shot.half)) else { return }
        switch half {
        case .first:
            shot.timeStamp = Int64(match.firstHalfTimeElapsed)
        case .second:
            shot.timeStamp = Int64(match.secondHalfTimeElapsed)
        case .extra:
            shot.timeStamp = Int64(match.extraTimeTimeElaspsed)
        }
        if let assistee = assistee {
            let assist = Assist(context: context)
            assist.half = playingTime.half
            assist.timeStamp = shot.timeStamp
            assist.goal = shot
            shot.assist = assist
            playingTime.addToAssists(assist)
        }
        playingTime.addToShots(shot)
        if shot.isGoal {
            switch teamType {
            case .home:
                App.sharedCore.fire(event: HomeGoalScored())
            case .away:
                App.sharedCore.fire(event: AwayGoalScored())
            }
        }
    }

    func addFoul(to player: SoccerPlayer, match: Match, teamType: TeamType) {
        guard let context = context else { return }
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
        let foul = Foul(context: context)
        foul.half = playingTime.half
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
