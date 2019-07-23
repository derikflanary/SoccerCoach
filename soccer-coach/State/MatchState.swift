//
//  MatchState.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/23/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation
import Combine

struct MatchState: State {
    
    @Published var currentMatch: Match?
    
    mutating func react(to event: Event) {
        switch event {
        case let event as Selected<Match>:
            currentMatch = event.item
        default:
            break
        }
    }
    
}
