//
//  SoccerPlayerController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/22/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct SoccerPlayerController {
    
    static var shared = SoccerPlayerController()
    
    var context: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
    
    func createPlayer(with name: String, number: String? = nil, isFiller: Bool = false) -> SoccerPlayer? {
        guard let context = context else { return nil }
        let player = SoccerPlayer(context: context)
        player.id = UUID().uuidString
        player.name = name
        player.number = number
        player.isFiller = isFiller
        do {
            try context.save()
        } catch {
            print(error)
        }
        return player
    }
    
    func fetchAllPlayers() -> [SoccerPlayer] {
        guard let context = context else { return [] }
        do {
            return try context.fetch(SoccerPlayer.fetchRequest()) as? [SoccerPlayer] ?? []
        } catch {
            return []
        }
    }
    
    func fetchAllFillerPlayers() -> [SoccerPlayer] {
        guard let context = context else { return [] }
        let request: NSFetchRequest<SoccerPlayer> = SoccerPlayer.fetchRequest()
        let predicate =  NSPredicate(format: "isFiller == YES")
        request.predicate = predicate
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
    
    func update(_ player: SoccerPlayer) {
        print(player.isUpdated)
        guard let context = context else { return }
        try? context.save()
    }
    
    func delete(_ player: SoccerPlayer) {
        context?.delete(player)
        try? context?.save()
    }

}
