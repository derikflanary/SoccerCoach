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
        let minute = self == 0 ? 1 : self
        switch half {
        case .first:
            return minute > halfLength ? "\(halfLength)'" : "\(minute)'"
        case .second:
            return "\(minute + halfLength)'"
        case .extra:
            return "\(minute + (halfLength * 2))'"
        }
    }
    
    func timeString() -> String {
            let mins = self.minutes
            let remainingSeconds = self - (mins * 60)
            let minuteString = mins < 10 ? "0\(mins)" : "\(mins)"
            let secondsString = remainingSeconds < 10 ? "0\(remainingSeconds)" : "\(remainingSeconds)"
            return "\(minuteString):\(secondsString)"
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
