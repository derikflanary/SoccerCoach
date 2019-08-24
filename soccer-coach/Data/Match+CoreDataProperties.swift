//
//  Match+CoreDataProperties.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/22/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData


extension Match {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Match> {
        return NSFetchRequest<Match>(entityName: "Match")
    }

    @NSManaged public var id: String
    @NSManaged public var date: Date
    @NSManaged public var halfLength: Int64
    @NSManaged public var homeTeam: Team?
    @NSManaged public var awayTeam: Team?
    @NSManaged public var score: Score?
    @NSManaged public var homePlayingTime: Set<PlayingTime>?
    @NSManaged public var awayPlayingTime: Set<PlayingTime>?
    @NSManaged public var half: Int64
    @NSManaged public var firstHalfCount: Int64
    @NSManaged public var secondHalfCount: Int64
    @NSManaged public var homeCornerCount: Int64
    @NSManaged public var awayCornerCount: Int64

}

// MARK: Generated accessors for homePlayingTime
extension Match {

    @objc(addHomePlayingTimeObject:)
    @NSManaged public func addToHomePlayingTime(_ value: PlayingTime)

    @objc(removeHomePlayingTimeObject:)
    @NSManaged public func removeFromHomePlayingTime(_ value: PlayingTime)

    @objc(addHomePlayingTime:)
    @NSManaged public func addToHomePlayingTime(_ values: NSSet)

    @objc(removeHomePlayingTime:)
    @NSManaged public func removeFromHomePlayingTime(_ values: NSSet)

}

// MARK: Generated accessors for awayPlayingTime
extension Match {

    @objc(addAwayPlayingTimeObject:)
    @NSManaged public func addToAwayPlayingTime(_ value: PlayingTime)

    @objc(removeAwayPlayingTimeObject:)
    @NSManaged public func removeFromAwayPlayingTime(_ value: PlayingTime)

    @objc(addAwayPlayingTime:)
    @NSManaged public func addToAwayPlayingTime(_ values: NSSet)

    @objc(removeAwayPlayingTime:)
    @NSManaged public func removeFromAwayPlayingTime(_ values: NSSet)

}
