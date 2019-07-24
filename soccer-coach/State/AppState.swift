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

struct AppState: State {
    
    @Published var matchState = MatchState()
    
    mutating func react(to event: Event) {
        switch event {
        default:
            break
        }
        matchState.react(to: event)
    }
    
}


struct MatchState: State {
    
    @Published var newMatchHomeTeam: Team?
    @Published var newMatchAwayTeam: Team?
    var currentMatch: Match?
    
    mutating func react(to event: Event) {
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
        default:
            break
        }
    }
    
}

enum TeamType {
    case home, away
}

struct NewMatchTeamSelected: Event {
    let teamType: TeamType
    let team: Team
}
