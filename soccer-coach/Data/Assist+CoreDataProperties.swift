//
//  Assist+CoreDataProperties.swift
//  soccer-coach
//
//  Created by Derik Flanary on 8/15/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData


extension Assist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assist> {
        return NSFetchRequest<Assist>(entityName: "Assist")
    }

    @NSManaged public var goal: Shot?
    @NSManaged public var playingTime: PlayingTime?

}
