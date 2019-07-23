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
    
//    @Published var matchState = MatchState()
    
    mutating func react(to event: Event) {
        switch event {
        default:
            break
        }
//        matchState.react(to: event)
    }
    
}
