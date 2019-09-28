//
//  PlayerPositionMatchDetail.swift
//  soccer-coach
//
//  Created by Derik Flanary on 9/28/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class PlayerPositionMatchDetail: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var playerMatchStats: PlayerMatchStats
    let cellIdentifier = "cell"
    var positions: [Position]
    
    // MARK: - Initializers
    
    init?(coder: NSCoder, playerMatchStats: PlayerMatchStats) {
        self.playerMatchStats = playerMatchStats
        positions = playerMatchStats.positions
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

extension PlayerPositionMatchDetail: UITableViewDataSource {
    
    enum Row: Int, CaseIterable {
        case minutes
        case totalTeamShots
        case teamShotsPerMinute
        case averageShotRating
        case plusMinus
                
        var title: String {
            switch self {
            case .minutes:
                return "Minutes Played"
            case .totalTeamShots:
                return "Total Team Shots"
            case .teamShotsPerMinute:
                return "Team Shots / Minute"
            case .averageShotRating:
                return "Average Team Shot Rating"
            case .plusMinus:
                return "+/-"
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
        case .minutes:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = "\(playerMatchStats.minutesPlayed(at: position))"
        case .totalTeamShots:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = "\(playerMatchStats.teamShots(at: position).count)"
        case .teamShotsPerMinute:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = String(format: "%.3f", playerMatchStats.teamShotsPerMinute(at: position))
        case .averageShotRating:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = "\(playerMatchStats.teamShotQualityAverage(at: position))"
        case .plusMinus:
            cell.textLabel?.text = "\(row.title):"
            cell.detailTextLabel?.text = "\(playerMatchStats.plusMinus(at: position))"
        }
        return cell
    }
    
}
