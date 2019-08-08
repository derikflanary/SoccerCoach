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
        case assits
        case fouls
        case cards
        
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
            case .assits:
                return "Assists"
            case .fouls:
                return "Fouls"
            case .cards:
                return "Cards"
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return playerMatchStats.playingTimes.isEmpty ? 0 : Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let section = Section(rawValue: indexPath.section) else { return cell }
        switch section {
        case .minutes:
            cell.textLabel?.text = "\(playerMatchStats.minutesPlayed)"
        case .positions:
            cell.textLabel?.text = playerMatchStats.positions.map { String($0.rawValue) }.joined(separator: ", ")
        case .goals:
            cell.textLabel?.text = "\(playerMatchStats.goals.count)"
        case .shots:
            cell.textLabel?.text = "\(playerMatchStats.shots.count)"
        case .onTarget:
            cell.textLabel?.text = "\(playerMatchStats.shotsOnTarget.count)"
        case .offTarget:
            cell.textLabel?.text = "\(playerMatchStats.shotsOffTarget.count)"
        case .averageShotRating:
            cell.textLabel?.text = "\(playerMatchStats.averageShotRating)"
        case .assits:
            cell.textLabel?.text = "\(playerMatchStats.assists.count)"
        case .fouls:
            cell.textLabel?.text = "\(playerMatchStats.fouls.count)"
        case .cards:
            cell.textLabel?.text = playerMatchStats.cards.isEmpty ? "-" : playerMatchStats.cards.map { $0.cardType.rawValue }.joined(separator: ", ")
        }
        return cell
    }
    
}
