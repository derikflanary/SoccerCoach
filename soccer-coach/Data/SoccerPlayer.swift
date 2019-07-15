//
//  Player.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit
import MobileCoreServices
import Combine

class SoccerPlayer: NSObject, Codable {
    
    var id = UUID()
    var name: String
    var isActive = false
    var number: String?
    var team: Team?
    
    
    init(name: String, number: String) {
        self.name = name
        self.number = number
    }
    
    init(name: String) {
        self.name = name
    }

}

extension SoccerPlayer: NSItemProviderWriting, NSItemProviderReading {
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData) as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
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
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData) as String]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
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
