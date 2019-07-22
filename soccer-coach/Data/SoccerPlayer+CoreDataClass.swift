//
//  SoccerPlayer+CoreDataClass.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/21/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//
//

import Foundation
import UIKit
import CoreData
import MobileCoreServices

public class SoccerPlayer: NSManagedObject, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case number
        case isActive
        case team
    }

    
    // MARK: - Decodable
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "SoccerPlayer", in: managedObjectContext)
        else { fatalError("Failed to decode player") }
        self.init(entity: entity, insertInto: managedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.isActive = try container.decode(Bool.self, forKey: .isActive)
        self.number = try container.decodeIfPresent(String.self, forKey: .id)
        self.team = try container.decode(Team.self, forKey: .team)
    }
    
    // MARK: - Encodable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(team, forKey: .team)
    }
    
}


// MARK: - NSItemProvider

extension SoccerPlayer: NSItemProviderWriting, NSItemProviderReading {
    
    public static var writableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData) as String]
    }
    
    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 100)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        return progress
    }
    
    public static var readableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData) as String]
    }
    
    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        let decoder = JSONDecoder()
        do {
            let player = try decoder.decode(SoccerPlayer.self, from: data)
            return player as! Self
        } catch {
            print(error)
            fatalError("error writing item provider for \(self)")
        }
    }
    
}


public extension CodingUserInfoKey {
    // Helper property to retrieve the Core Data managed object context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
