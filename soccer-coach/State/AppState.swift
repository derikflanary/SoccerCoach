//
//  AppState.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/23/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation
import Combine

enum App {
    
    static var sharedCore = Core(state: AppState(), middlewares: [])
    
}

class AppState: State {
    
    var matchState = MatchState()
    
    func react(to event: Event) {
        switch event {
        default:
            break
        }
        matchState.react(to: event)
    }
    
}


class MatchState: State {
    
    @Published var newMatchHomeTeam: Team? = nil
    @Published var newMatchAwayTeam: Team? = nil
    @Published var currentMatch: Match? = nil
    @Published var selectedTeamType: TeamType = .home
    @Published var homeGoals: Int = 0
    @Published var awayGoals: Int = 0
    
    func react(to event: Event) {
        switch event {
        case let event as Selected<Match?>:
            currentMatch = event.item
            newMatchHomeTeam = nil
            newMatchAwayTeam = nil
        case let event as NewMatchTeamSelected:
            switch event.teamType {
            case .home:
                newMatchHomeTeam = event.team
            case .away:
                newMatchAwayTeam = event.team
            }
        case let event as Selected<TeamType>:
            selectedTeamType = event.item
        case _ as HomeGoalScored:
            homeGoals += 1
        case _ as AwayGoalScored:
            awayGoals += 1
        default:
            break
        }
    }
    
}

enum TeamType: Int, CaseIterable {
    case home, away
}

struct NewMatchTeamSelected: Event {
    let teamType: TeamType
    let team: Team
}
