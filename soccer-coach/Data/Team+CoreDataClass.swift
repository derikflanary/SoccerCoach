//
//  Team+CoreDataClass.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/21/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import CoreData

public class Team: NSManagedObject, Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case players
    }
    
    // MARK: - Decodable
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Team", in: managedObjectContext)
            else { fatalError("Failed to decode Team") }
        self.init(entity: entity, insertInto: managedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.players = try container.decode(Set<SoccerPlayer>.self, forKey: .players)
    }
    
    // MARK: - Encodable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(players, forKey: .players)
    }
}
