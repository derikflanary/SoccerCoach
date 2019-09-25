//
//  MatchDetailDataSource.swift
//  soccer-coach
//
//  Created by Derik Flanary on 9/11/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class MatchDetailDataSource: NSObject {

    var match: Match?
    var players = [SoccerPlayer]()
    var teamType: TeamType = .home
    let cellIdentifier = "cell"
    
    var matchStats: MatchStats {
        return MatchStats(match: match)
    }
    
}


extension MatchDetailDataSource: UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case shots
        case onTarget
        case offTarget
        case shotQuality
        case corners
        case assists
        case fouls
        case players
        
        var title: String {
            switch self {
            case .shots:
                return "Shots"
            case .onTarget:
                return "Shots on Target"
            case .offTarget:
                return "Shots off Target"
            case .shotQuality:
                return "Average Shot Quality"
            case .corners:
                return "Corners"
            case .assists:
                return "Assists"
            case .fouls:
                return "Fouls"
            case .players:
                return "Players"
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .players:
            return players.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        return section.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let section = Section(rawValue: indexPath.section), let match = match else { return UITableViewCell() }
        switch section {
        case .shots:
            switch teamType {
            case .home:
                cell.textLabel?.text = "\(matchStats.homeTotalShots)"
            case .away:
                cell.textLabel?.text = "\(matchStats.awayTotalShots)"
            }
            return cell
        case .onTarget:
            switch teamType {
            case .home:
                cell.textLabel?.text = "\(matchStats.homeShotsOnTarget)"
            case .away:
                cell.textLabel?.text = "\(matchStats.awayShotsOnTarget)"
            }
            return cell
        case .offTarget:
            switch teamType {
            case .home:
                cell.textLabel?.text = "\(matchStats.homeShotsOffTarget)"
            case .away:
                cell.textLabel?.text = "\(matchStats.awayShotsOffTarget)"
            }
            return cell
        case .shotQuality:
            switch teamType {
            case .home:
                cell.textLabel?.text = "\(matchStats.homeAverageShotQuality)"
            case .away:
                cell.textLabel?.text = "\(matchStats.awayAverageShotQuality)"
            }
            return cell
        case .corners:
            switch teamType {
            case .home:
                cell.textLabel?.text = "\(match.homeCornerCount)"
            case .away:
                cell.textLabel?.text = "\(match.awayCornerCount)"
            }
            return cell
        case .assists:
            switch teamType {
            case .home:
                cell.textLabel?.text = "\(matchStats.homeAssistsTotal)"
            case .away:
                cell.textLabel?.text = "\(matchStats.awayAssistsTotal)"
            }
            return cell
        case .fouls:
            switch teamType {
            case .home:
                cell.textLabel?.text = "\(matchStats.homeFoulsTotal)"
            case .away:
                cell.textLabel?.text = "\(matchStats.awayFoulsTotal)"
            }
            return cell
        case .players:
            let playerCell = tableView.dequeueReusableCell(withIdentifier: PlayerDetailCell.reuseIdentifier, for: indexPath) as! PlayerDetailCell
            let player = players[indexPath.row]
            var playingTimes = [PlayingTime]()
            switch teamType {
            case .home:
                playingTimes = match.homePlayingTime?.filter { $0.player == player }.compactMap { $0 } ?? []
            case .away:
                playingTimes = match.awayPlayingTime?.filter { $0.player == player }.compactMap { $0 } ?? []
            }
            let playerMatchStats = PlayerMatchStats(player: player, playingTimes: playingTimes, match: match)
            playerCell.configure(with: playerMatchStats)
            playerCell.accessoryType = .disclosureIndicator
            return playerCell
        }
    }
    
}
