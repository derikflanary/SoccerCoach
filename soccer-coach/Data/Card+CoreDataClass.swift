//
//  Card+CoreDataClass.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/22/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData


public class Card: NSManagedObject {
    
    var cardType: CardType {
        return CardType(rawValue: self.type) ?? .yellow
    }
    
}
