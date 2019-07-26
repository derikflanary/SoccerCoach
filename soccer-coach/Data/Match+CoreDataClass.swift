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

    var hasStarted = false
    var timerPublisher = Timer.publish(every: 1, on: .main, in: .default)
    var timerAnyCancellable: AnyCancellable? = nil
    var enterBackgroundCancellable: AnyCancellable? = nil
    var becomeActiveCancellable: AnyCancellable? = nil
    var savedDate = Date()

    @Published var firstHalfTimeElapsed: TimeInterval = 0
    @Published var secondHalfTimeElapsed: TimeInterval = 0
    @Published var extraTimeTimeElaspsed: TimeInterval = 0

    var currentHalf: Half {
        return Half(rawValue: Int(half)) ?? .first
    }
    var timerSubscriber: Subscribers.Sink<Date, Never> {
        return timerPublisher
            .autoconnect()
            .sink(receiveValue: { _ in
                switch self.currentHalf {
                case .first:
                    self.firstHalfTimeElapsed += 1
                case .second:
                    self.secondHalfTimeElapsed += 1
                case .extra:
                    self.extraTimeTimeElaspsed += 1
                }
            })
    }
    
    func start() {
        let backgroundSub = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .map({ _ -> Date in
                return Date()
            })
            .print()
            .sink(receiveValue: { date in
                self.pause()
            })
        enterBackgroundCancellable = AnyCancellable(backgroundSub)
            
        let activeSub = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .map({ _ -> TimeInterval in
                return Date().timeIntervalSince(self.savedDate)
            })
            .sink(receiveValue: { timeInterval in
                switch self.currentHalf {
                case .first:
                    self.firstHalfTimeElapsed += 1
                case .second:
                    self.secondHalfTimeElapsed += 1
                case .extra:
                    self.extraTimeTimeElaspsed += 1
                }
                self.resume()
            })
        becomeActiveCancellable = AnyCancellable(activeSub)

        timerAnyCancellable = AnyCancellable(timerSubscriber)
        savedDate = Date()
    }
    
    func pause() {
        timerAnyCancellable?.cancel()
    }
    
    func resume() {
        timerPublisher = Timer.publish(every: 1, on: .main, in: .default)
        timerAnyCancellable = AnyCancellable(timerSubscriber)
        savedDate = Date()
    }
    
}
