//
//  Assist+CoreDataProperties.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/22/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData


extension Assist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assist> {
        return NSFetchRequest<Assist>(entityName: "Assist")
    }

    @NSManaged public var timeStamp: Int64
    @NSManaged public var half: Int64
    @NSManaged public var playingTime: PlayingTime?

}
