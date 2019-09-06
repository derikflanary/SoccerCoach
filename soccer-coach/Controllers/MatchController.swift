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
    
    func end(_ match: Match, homeCornerCount: Int64, awayCornerCount: Int64) {
        if let homeTeam = match.homeTeam {
            for player in homeTeam.players {
                PlayingTimeController.shared.endPlayingTime(for: player, match: match, teamType: .home, endTime: Int(match.halfLength))
            }
        }
        if let awayTeam = match.awayTeam {
            for player in awayTeam.players {
                PlayingTimeController.shared.endPlayingTime(for: player, match: match, teamType: .away, endTime: Int(match.halfLength * 2))
            }
        }
        match.homeCornerCount = homeCornerCount
        match.awayCornerCount = awayCornerCount
        save(match)
    }
    
    func save(_ match: Match) {
        guard let context = context else { return }
        try? context.save()
    }
    
    func delete(_ match: Match) {
        guard let context = context else { return }
        context.delete(match)
        try? context.save()
    }
    
}

