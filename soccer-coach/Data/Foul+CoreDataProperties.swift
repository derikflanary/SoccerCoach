//
//  Foul+CoreDataProperties.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/22/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData


extension Foul {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Foul> {
        return NSFetchRequest<Foul>(entityName: "Foul")
    }

    @NSManaged public var timeStamp: Int64
    @NSManaged public var half: Int64
    @NSManaged public var playingTime: PlayingTime?

}
