//
//  CurrentMatchPlayerDetails.swift
//  soccer-coach
//
//  Created by Derik Flanary on 8/7/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class CurrentMatchPlayerDetails: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var emptyStateView: UIView!
    
    var playerMatchStats: PlayerMatchStats
    let cellIdentifier = "cell"
    var selectedShot: Shot?
    
    
    // MARK: - Initializers
    
    init?(coder: NSCoder, playerMatchStats: PlayerMatchStats) {
        self.playerMatchStats = playerMatchStats
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundView = playerMatchStats.playingTimes.isEmpty ? emptyStateView : nil
        tableView.reloadData()
    }
    
    @IBSegueAction func showShotDetail(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UIViewController? {
        guard let shot = selectedShot else { return nil }
        return ShotDetail(coder: coder, shot: shot, match: playerMatchStats.match)
    }
    @IBSegueAction func showPositionDetail(_ coder: NSCoder) -> UIViewController? {
        return PlayerPositionMatchDetail(coder: coder, playerMatchStats: playerMatchStats)
    }
    
}


// MARK: - Tableview datasource

extension CurrentMatchPlayerDetails: UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case minutes
        case positions
        case goals
        case shots
        case onTarget
        case offTarget
        case averageShotRating
        case assists
        case fouls
        case cards
        case turnovers
        case saves
        
        var title: String {
            switch self {
            case .minutes:
                return "Minutes Played"
            case .positions:
                return "Positions"
            case .goals:
                return "Goals"
            case .shots:
                return "Shots"
            case .onTarget:
                return "Shots on Target"
            case .offTarget:
                return "Shots off Target"
            case .averageShotRating:
                return "Average Shot Rating"
            case .assists:
                return "Assists"
            case .fouls:
                return "Fouls"
            case .cards:
                return "Cards"
            case .turnovers:
                return "Turnovers"
            case .saves:
                return "Saves"
            }
        }
    }
    
    enum TurnoverRow: Int, CaseIterable {
        case badPass
        case badTouch
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return playerMatchStats.playingTimes.isEmpty ? 0 : Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .minutes:
            return 1
        case .positions:
            return 1
        case .goals:
            return playerMatchStats.goals.count
        case .shots:
            return 1
        case .onTarget:
            return playerMatchStats.shotsOnTarget.count
        case .offTarget:
            return playerMatchStats.shotsOffTarget.count
        case .averageShotRating:
            return 1
        case .assists:
            return 1
        case .fouls:
            return 1
        case .cards:
            return 1
        case .turnovers:
            return 2
        case .saves:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let section = Section(rawValue: indexPath.section) else { return cell }
        switch section {
        case .minutes:
            cell.textLabel?.text = "\(playerMatchStats.minutesPlayed)"
            cell.accessoryType = .none
        case .positions:
            cell.textLabel?.text = playerMatchStats.positions.map { String($0.rawValue) }.joined(separator: ", ")
            cell.accessoryType = .disclosureIndicator
        case .goals:
            let goal = playerMatchStats.goals[indexPath.row]
            cell.textLabel?.text = goal.minuteString(halfLength: Int(playerMatchStats.match.halfLength))
            cell.accessoryType = .disclosureIndicator
        case .shots:
            cell.textLabel?.text = "\(playerMatchStats.shots.count)"
            cell.accessoryType = .none
        case .onTarget:
            let shot = playerMatchStats.shotsOnTarget[indexPath.row]
            cell.textLabel?.text = shot.minuteString(halfLength: Int(playerMatchStats.match.halfLength))
            cell.accessoryType = .disclosureIndicator
        case .offTarget:
            let shot = playerMatchStats.shotsOffTarget[indexPath.row]
            cell.textLabel?.text = shot.minuteString(halfLength: Int(playerMatchStats.match.halfLength))
            cell.accessoryType = .disclosureIndicator
        case .averageShotRating:
            cell.textLabel?.text = "\(playerMatchStats.averageShotRating)"
            cell.accessoryType = .none
        case .assists:
            cell.textLabel?.text = "\(playerMatchStats.assists.count)"
            cell.accessoryType = .none
        case .fouls:
            cell.textLabel?.text = "\(playerMatchStats.fouls.count)"
            cell.accessoryType = .none
        case .cards:
            cell.textLabel?.text = playerMatchStats.cards.isEmpty ? "-" : playerMatchStats.cards.map { $0.cardType.rawValue }.joined(separator: ", ")
            cell.accessoryType = .none
        case .turnovers:
            let turnoverRow = TurnoverRow(rawValue: indexPath.row)
            switch turnoverRow {
            case .badPass:
                cell.textLabel?.text = "Poor Passes: \(playerMatchStats.badPasses.count)"
            case .badTouch:
                cell.textLabel?.text = "Poor Touches: \(playerMatchStats.badTouches.count)"
            case .none:
                break
            }
            cell.accessoryType = .none
        case .saves:
            cell.textLabel?.text = "\(playerMatchStats.saves.count)"
            cell.accessoryType = .none
        }
        return cell
    }
    
}


// MARK: - Tableview delgate

extension CurrentMatchPlayerDetails: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .positions:
            performSegue(withIdentifier: .showPositionDetail, sender: nil)
        case .goals:
            selectedShot = playerMatchStats.goals[indexPath.row]
            performSegue(withIdentifier: .showShotDetail, sender: nil)
        case .onTarget:
            selectedShot = playerMatchStats.shotsOnTarget[indexPath.row]
            performSegue(withIdentifier: .showShotDetail, sender: nil)
        case .offTarget:
            selectedShot = playerMatchStats.shotsOffTarget[indexPath.row]
            performSegue(withIdentifier: .showShotDetail, sender: nil)
        default:
            break
        }
    }
    
}


// MARK: - Segue handling

extension CurrentMatchPlayerDetails: SegueHandling {
    
    enum SegueIdentifier: String {
        case showShotDetail
        case showPositionDetail
    }
    
}
