//
//  Team.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/14/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

struct Team: Codable {
    
    let id = UUID()
    let name: String
    var players: [SoccerPlayer]
    
}

extension Team: Hashable {
    
}
