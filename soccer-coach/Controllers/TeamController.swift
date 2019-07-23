//
//  TeamController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/23/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct TeamController {
    
    static var shared = TeamController()
    
    var context: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
    
    func createTeam(with name: String, players: [SoccerPlayer]) -> Team? {
        guard let context = context else { return nil }
        let team = Team(context: context)
        team.id = UUID().uuidString
        team.name = name
        team.players = Set(players)
        try? context.save()
        return team
    }
    
    func fetchAllTeams() -> [Team] {
        guard let context = context else { return [] }
        do {
            return try context.fetch(Team.fetchRequest()) as? [Team] ?? []
        } catch {
            return []
        }
    }
    
}
