//
//  MatchController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/23/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct MatchController {
    
    static var shared = MatchController()
    
    var context: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
    
    func createMatch(with homeTeam: Team, awayTeam: Team, halfLength: Int = 40, date: Date = Date()) -> Match? {
        guard let context = context else { return nil }
        let match = Match(context: context)
        match.id = UUID().uuidString
        homeTeam.players.forEach {
            $0.isActive = false
        }
        awayTeam.players.forEach {
            $0.isActive = false
        }
        match.homeTeam = homeTeam
        match.awayTeam = awayTeam
        match.halfLength = Int64(halfLength)
        match.date = date
        match.score = Score(context: context)
        return match
    }
    
    func fetchAllMatches() -> [Match] {
        guard let context = context else { return [] }
        do {
            return try context.fetch(Match.fetchRequest()) as? [Match] ?? []
        } catch {
            return []
        }
    }
    
    func save(_ match: Match) {
        guard let context = context else { return }
        try? context.save()
    }
    
    
    // MARK: - Playing time
    
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
        var pTime: PlayingTime?
        switch teamType {
        case .home:
            pTime = match.homePlayingTime?.first(where: { (playingTime) -> Bool in
                return playingTime.player == player && playingTime.isActive
            })
        case .away:
            pTime = match.awayPlayingTime?.first(where: { (playingTime) -> Bool in
                return playingTime.player == player && playingTime.isActive
            })
        }
        guard let playingTime = pTime else { return }
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
        print(playingTime)
    }
}

