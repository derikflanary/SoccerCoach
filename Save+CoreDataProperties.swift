//
//  Save+CoreDataProperties.swift
//  soccer-coach
//
//  Created by Derik Flanary on 8/28/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData


extension Save {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Save> {
        return NSFetchRequest<Save>(entityName: "Save")
    }

    @NSManaged public var half: Int64
    @NSManaged public var timeStamp: Int64
    @NSManaged public var playingTime: PlayingTime?

}
