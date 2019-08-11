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

    var timerPublisher = Timer.publish(every: 1, tolerance: 0, on: .current, in: .default, options: nil)
    var timerAnyCancellable: AnyCancellable? = nil
    var enterBackgroundCancellable: AnyCancellable? = nil
    var becomeActiveCancellable: AnyCancellable? = nil
    var savedDate = Date()

    @Published var hasStarted = false
    @Published var firstHalfTimeElapsed: TimeInterval = 0
    @Published var secondHalfTimeElapsed: TimeInterval = 0
    @Published var extraTimeTimeElaspsed: TimeInterval = 0

    var summary: String {
        guard let homeTeam = homeTeam, let awayTeam = awayTeam else { return ""}
        return "\(homeTeam.name) \(homeGoals) - \(awayGoals) \(awayTeam.name)"
    }
    var currentHalf: Half {
        return Half(rawValue: Int(half)) ?? .first
    }
    var homeGoals: Int {
        let shots = homePlayingTime?.compactMap { $0.shots }.flatMap { $0 }
        return shots?.filter { $0.isGoal }.count ?? 0
    }
    var awayGoals: Int {
        let shots = awayPlayingTime?.compactMap { $0.shots }.flatMap { $0 }
        return shots?.filter { $0.isGoal }.count ?? 0
    }
    var isComplete: Bool {
        return firstHalfTimeElapsed >= TimeInterval(halfLength) && secondHalfTimeElapsed >= TimeInterval(halfLength)
    }
    var timerSubscriber: AnyCancellable {
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
            .print()
            .sink(receiveValue: { _ in
                self.savedDate = Date()
                self.pause()
            })
        enterBackgroundCancellable = AnyCancellable(backgroundSub)
            
        let activeSub = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .map({ _ -> TimeInterval in
                return Date().timeIntervalSince(self.savedDate)
            })
            .print()
            .sink(receiveValue: { timeInterval in
                switch self.currentHalf {
                case .first:
                    self.firstHalfTimeElapsed += timeInterval
                case .second:
                    self.secondHalfTimeElapsed += timeInterval
                case .extra:
                    self.extraTimeTimeElaspsed += timeInterval
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
        timerPublisher = Timer.publish(every: 1, tolerance: 0, on: .current, in: .default, options: nil)
        timerAnyCancellable = AnyCancellable(timerSubscriber)
        savedDate = Date()
    }
    
}
