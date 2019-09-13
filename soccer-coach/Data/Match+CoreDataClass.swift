//
//  Match+CoreDataClass.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/22/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit
import Combine

public class Match: NSManagedObject {
    
    var isOver = false

    var summary: String {
        let homeTeamName = homeTeam?.name ?? "Home Team"
        let awayTeamName = awayTeam?.name ?? "Away Team"
        let homeScore = max(score?.home ?? 0, Int64(homeGoals))
        let awayScore = max(score?.away ?? 0, Int64(awayGoals))
        return "\(homeTeamName) \(homeScore) - \(awayScore) \(awayTeamName)"
    }
    var currentHalf: Half {
        return Half(rawValue: Int(half)) ?? .first
    }
    var homeGoals: Int {
        let shots = homePlayingTime?.compactMap { $0.shots }.flatMap { $0 }
        return shots?.filter { $0.isGoal }.count ?? 0
    }
    var awayGoals: Int {
        let shots = awayPlayingTime?.compactMap { $0.shots }.flatMap { $0 }
        return shots?.filter { $0.isGoal }.count ?? 0
    }
    
}
