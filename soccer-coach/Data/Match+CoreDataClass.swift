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
    var isRunning = false

    @Published var halfHasStarted = false
    @Published var firstHalfTimeElapsed: TimeInterval = 0
    @Published var secondHalfTimeElapsed: TimeInterval = 0
    @Published var extraTimeTimeElaspsed: TimeInterval = 0

    var summary: String {
        let homeTeamName = homeTeam?.name ?? "Home Team"
        let awayTeamName = awayTeam?.name ?? "Away Team"
        return "\(homeTeamName) \(homeGoals) - \(awayGoals) \(awayTeamName)"
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
    
    var becomeActiveSubscriber: AnyCancellable {
        return NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .map({ _ -> TimeInterval in
                return Date().timeIntervalSince(self.savedDate)
            })
            .sink(receiveValue: { timeInterval in
                guard self.isRunning else { return }
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
    }
    
    var enterBackgroundSubscriber: AnyCancellable {
        return NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink(receiveValue: { _ in
                guard self.isRunning else { return }
                self.savedDate = Date()
                self.timerAnyCancellable?.cancel()
            })
    }
    
    func start() {
        timerPublisher = Timer.publish(every: 1, tolerance: 0, on: .current, in: .default, options: nil)
        enterBackgroundCancellable = enterBackgroundSubscriber
        becomeActiveCancellable = becomeActiveSubscriber
        timerAnyCancellable = AnyCancellable(timerSubscriber)
        savedDate = Date()
        isRunning = true
        if !halfHasStarted {
            halfHasStarted = true
        }
    }
    
    func pause() {
        isRunning = false
        timerAnyCancellable?.cancel()
    }
    
    func resume() {
        timerPublisher = Timer.publish(every: 1, tolerance: 0, on: .current, in: .default, options: nil)
        timerAnyCancellable = AnyCancellable(timerSubscriber)
        savedDate = Date()
    }
    
}
