//
//  Player.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class SoccerPlayer: NSObject, Codable {

    var id = UUID()
    var name: String
    var number: String?
    var positions = [String]()
    
    
    init(name: String, number: String, positions: [String]) {
        self.name = name
        self.number = number
        self.positions = positions
    }
    
    init(name: String) {
        self.name = name
    }

}
