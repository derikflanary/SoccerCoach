//
//  GenericEvents.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/23/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation

struct Created<T>: Event {
    let item: T
}

struct Selected<T>: Event {
    var item: T
}

struct Deselected<T>: Event { }

struct Updated<T>: Event {
    var item: T
}

struct Added<T>: Event {
    var item: T
}

struct Deleted<T>: Event {
    var item: T
}

struct Reset<T>: Event {
    var customReset: ((T) -> T)?
}

struct HomeGoalScored: Event { }

struct AwayGoalScored: Event { }

struct HalfStarted: Event { }

struct HalfEnded: Event { }
