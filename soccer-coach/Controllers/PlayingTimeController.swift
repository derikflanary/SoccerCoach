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
    
    func playingTime(for player: SoccerPlayer?, match: Match, teamType: TeamType) -> PlayingTime? {
        if let player = player {
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
        } else {
            return nil
        }
    }
    
    func playingTimes(for player: SoccerPlayer, match: Match, teamType: TeamType) -> [PlayingTime] {
        switch teamType {
        case .home:
            return match.homePlayingTime?.filter { $0.player == player }.compactMap { $0 } ?? []
        case .away:
             return match.awayPlayingTime?.filter { $0.player == player }.compactMap { $0 } ?? []
        }
    }
    
    func addGeneralTeamPlayingTime(to match: Match, teamType: TeamType) {
        guard let context = context else { return }
        let playingTime = PlayingTime(context: context)
        playingTime.player = nil
        playingTime.half = match.half
        playingTime.isActive = true
        playingTime.positionValue = 0
        playingTime.startTime = match.currentHalf.minute(for: 0, halfLength: match.halfLength)
        playingTime.endTime = match.currentHalf.minute(for: Int(match.halfLength), halfLength: match.halfLength)
        switch teamType {
        case .home:
            match.addToHomePlayingTime(playingTime)
        case .away:
            match.addToAwayPlayingTime(playingTime)
        }
        print("began: \(playingTime)")
    }
    
    func addPlayingTime(to match: Match, for player: SoccerPlayer, teamType: TeamType, position: Position, startTime: Int) {
        guard let context = context else { return }
        let playingTime = PlayingTime(context: context)
        playingTime.player = player
        playingTime.half = match.half
        playingTime.isActive = true
        playingTime.positionValue = Int64(position.rawValue)
        playingTime.startTime = match.currentHalf.minute(for: startTime, halfLength: match.halfLength)
        
        switch teamType {
        case .home:
            match.addToHomePlayingTime(playingTime)
        case .away:
            match.addToAwayPlayingTime(playingTime)
        }
        print("began: \(playingTime)")
    }
    
    func endPlayingTime(for player: SoccerPlayer, match: Match, teamType: TeamType, endTime: Int) {
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType), playingTime.isActive else { return }
        playingTime.isActive = false
        playingTime.endTime = match.currentHalf.minute(for: endTime, halfLength: match.halfLength)
        if playingTime.startTime == playingTime.endTime {
            context?.delete(playingTime)
            print("deleted: \(playingTime)")
        } else {
            print("ended: \(playingTime)")
        }
    }
    
    func addShot(to player: SoccerPlayer?, match: Match, teamType: TeamType, rating: Int, onTarget: Bool, isGoal: Bool, description: String? = nil, timeStamp: Int, assistee: SoccerPlayer?) {
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
        shot.timeStamp = Int64(match.currentHalf.minute(for: timeStamp, halfLength: match.halfLength))
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
    
    func deleteShot(_ shot: Shot) {
        guard let context = context else { return }
        context.delete(shot)
        try? context.save()
    }
    
    func addTurnover(to player: SoccerPlayer?, match: Match, teamType: TeamType, badPass: Bool, badTouch: Bool, timeStamp: Int) {
        guard let context = context else { return }
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
        let turnover = Turnover(context: context)
        turnover.isBadPass = badPass
        turnover.isBadTouch = badTouch
        turnover.half = playingTime.half
        turnover.timeStamp = Int64(match.currentHalf.minute(for: timeStamp, halfLength: match.halfLength))
        playingTime.addToTurnovers(turnover)
    }
    

    func addFoul(to player: SoccerPlayer?, match: Match, teamType: TeamType, isOffsides: Bool, timeStamp: Int) {
        guard let context = context else { return }
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
        let foul = Foul(context: context)
        foul.half = playingTime.half
        foul.isOffsides = isOffsides
        foul.timeStamp = Int64(match.currentHalf.minute(for: timeStamp, halfLength: match.halfLength))
        playingTime.addToFouls(foul)
    }
    
    func addCard(to player: SoccerPlayer?, match: Match, teamType: TeamType, cardType: CardType, timeStamp: Int) {
        guard let context = context else { return }
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
        let card = Card(context: context)
        card.half = playingTime.half
        card.type = cardType.rawValue
        card.timeStamp = Int64(match.currentHalf.minute(for: timeStamp, halfLength: match.halfLength))
        playingTime.addToCards(card)
    }
    
    func addSave(to player: SoccerPlayer?, match: Match, teamType: TeamType, timeStamp: Int) {
        guard let context = context else { return }
        guard let playingTime = playingTime(for: player, match: match, teamType: teamType) else { return }
        let save = Save(context: context)
        save.half = playingTime.half
        save.timeStamp = Int64(match.currentHalf.minute(for: timeStamp, halfLength: match.halfLength))
        playingTime.addToSaves(save)
    }
        
}
