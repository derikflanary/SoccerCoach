//
//  Turnover+CoreDataProperties.swift
//  soccer-coach
//
//  Created by Derik Flanary on 8/13/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData


extension Turnover {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Turnover> {
        return NSFetchRequest<Turnover>(entityName: "Turnover")
    }

    @NSManaged public var half: Int64
    @NSManaged public var timeStamp: Int64
    @NSManaged public var isBadPass: Bool
    @NSManaged public var isBadTouch: Bool
    @NSManaged public var playingTime: PlayingTime?

}
