//
//  PlayerPositionMatchDetail.swift
//  soccer-coach
//
//  Created by Derik Flanary on 9/28/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class PlayerPositionCumulativeDetail: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var playerStats: PlayerCumulativeStats
    let cellIdentifier = "cell"
    var positions: [Position]
    
    // MARK: - Initializers
    
    init?(coder: NSCoder, playerStats: PlayerCumulativeStats) {
        self.playerStats = playerStats
        positions = playerStats.positions
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}


// MARK: - Tableview datasource

extension PlayerPositionCumulativeDetail: UITableViewDataSource {
    
    enum Row: Int, CaseIterable {
        case minutesPerGame
        case teamShotsPerGame
        case teamShotsPerMinute
        case averageTeamShotRating
        case plusMinus
        case personalShotsPerGame
        case personalShotRating
                
        var title: String {
            switch self {
            case .minutesPerGame:
                return "Minutes Per Game"
            case .teamShotsPerGame:
                return "Average Team Shots Per Game"
            case .teamShotsPerMinute:
                return "Team Shots Per Minute Played"
            case .averageTeamShotRating:
                return "Average Team Shot Rating"
            case .plusMinus:
                return "+/-"
            case .personalShotsPerGame:
                return "Personal Shots Per Game"
            case .personalShotRating:
                return "Average Personal Shot Rating"
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return positions.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(positions[section].rawValue)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let position = positions[indexPath.section]
        guard let row = Row(rawValue: indexPath.row) else { return cell }
        switch row {
        case .minutesPerGame:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = "\(playerStats.minutesPerGame(for: position))"
        case .teamShotsPerGame:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = "\(playerStats.teamShotsPerGame(for: position))"
        case .teamShotsPerMinute:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = String(format: "%.1f", playerStats.teamShotsPerMinute(for: position))
        case .averageTeamShotRating:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = "\(playerStats.averageTeamShotRating(for: position))"
        case .plusMinus:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = "\(playerStats.plusMinus(for: position))"
        case .personalShotsPerGame:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = String(format: "%.1f", playerStats.personalShotsPerGame(for: position))
        case .personalShotRating:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = "\(playerStats.personalShotRatingAverage(for: position))"
        }
        return cell
    }
    
}
