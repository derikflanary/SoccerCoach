//
//  TimeInterval+Extensions.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/25/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

extension Int {
    
    var seconds: Int {
        return self
    }
    
    var minutes: Int {
        return self / 60
    }
    
    var hours: Int {
        return minutes / 60
    }
    
    var days: Int {
        return hours / 24
    }
    
    var weeks: Int {
        return days / 7
    }
    
    func minute(halfLength: Int, half: Half) -> String {
        let time = half.rawValue * halfLength
        if self > time {
            return "Extra time"
        } else {
            let minute = time / self
            return "\(minute)th minute"
        }
    }
    
    func shotRatingDescription() -> String {
        switch self {
        case 0:
            return "Impossible shot"
        case 1...25:
            return "Poor quality shot"
        case 26...40:
            return "Low quality shot"
        case 41...59:
            return "Average quality shot"
        case 60...75:
            return "Good quality shot"
        case 76...99:
            return "Great quality shot"
        case 100:
            return "Penalty Kick"
        default:
            return ""
        }
    }
    
}


enum CardType: String {
    case red, yellow
}

enum Half: Int {
    case first, second, extra
}
