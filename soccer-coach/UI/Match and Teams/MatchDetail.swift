//
//  MatchDetail.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/29/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class MatchDetail: UIViewController {
    
    enum Section: Int, CaseIterable {
        case home
        case away
    }

    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var awayTableView: UITableView!
    @IBOutlet weak var homeSectionHeaderTitleLabel: UILabel!
    @IBOutlet weak var awaySectionHeaderTitleLabel: UILabel!
    @IBOutlet var homeDataSource: MatchDetailDataSource!
    @IBOutlet var awayDataSource: MatchDetailDataSource!
    
    // MARK: - Properties
        
    var match: Match?
    var selectedPlayer: SoccerPlayer? = nil
    var playerTeamType: TeamType = .home

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = false
        homeTableView.register(UITableViewCell.self, forCellReuseIdentifier: homeDataSource.cellIdentifier)
        awayTableView.register(UITableViewCell.self, forCellReuseIdentifier: awayDataSource.cellIdentifier)
        homeDataSource.match = match
        awayDataSource.match = match
        homeDataSource.teamType = .home
        awayDataSource.teamType = .away
        guard let match = match else { return }
        homeDataSource.players = match.homeTeam?.players.sorted { playerOne, playerTwo -> Bool in
            let playingTimesOne = match.homePlayingTime?.filter { $0.player == playerOne }.compactMap { $0 } ?? []
            let playingTimesTwo = match.homePlayingTime?.filter { $0.player == playerTwo }.compactMap { $0 } ?? []
            let statsOne = PlayerMatchStats(player: playerOne, playingTimes: playingTimesOne, match: match)
            let statsTwo = PlayerMatchStats(player: playerTwo, playingTimes: playingTimesTwo, match: match)
            return statsOne.minutesPlayed > statsTwo.minutesPlayed
        } ?? []
        awayDataSource.players = match.awayTeam?.players.sorted { playerOne, playerTwo -> Bool in
            let playingTimesOne = match.awayPlayingTime?.filter { $0.player == playerOne }.compactMap { $0 } ?? []
            let playingTimesTwo = match.awayPlayingTime?.filter { $0.player == playerTwo }.compactMap { $0 } ?? []
            let statsOne = PlayerMatchStats(player: playerOne, playingTimes: playingTimesOne, match: match)
            let statsTwo = PlayerMatchStats(player: playerTwo, playingTimes: playingTimesTwo, match: match)
            return statsOne.minutesPlayed > statsTwo.minutesPlayed
        } ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let match = match else { return }
        title = match.summary
        homeSectionHeaderTitleLabel.text = match.homeTeam?.name
        awaySectionHeaderTitleLabel.text = match.awayTeam?.name
        homeTableView.reloadData()
        awayTableView.reloadData()
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let match = match else { return }
        let alert = UIAlertController(title: "Delete Match?", message: "Are you sure you want to delete this match?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            MatchController.shared.delete(match)
            self.performSegue(withIdentifier: .unwindToHistory, sender: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBSegueAction func showMatchPlayerDetails(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UIViewController? {
        guard let player = selectedPlayer, let match = match else { return nil }
        let playingTime = PlayingTimeController.shared.playingTimes(for: player, match: match, teamType: playerTeamType)
        let playerMatchStats = PlayerMatchStats(player: player, playingTimes: playingTime, match: match)
        return CurrentMatchPlayerDetails(coder: coder, playerMatchStats: playerMatchStats)
    }
    
}


extension MatchDetail: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = MatchDetailDataSource.Section(rawValue: indexPath.section), section == .players else { return }
        
        if tableView == homeTableView {
            selectedPlayer = homeDataSource.players[indexPath.row]
            playerTeamType = .home
        }
        if tableView == awayTableView {
            selectedPlayer = awayDataSource.players[indexPath.row]
            playerTeamType = .away
        }
        performSegue(withIdentifier: .showMatchPlayerDetails, sender: nil)
    }
    
}


// MARK: - Segue handling

extension MatchDetail: SegueHandling {
    
    enum SegueIdentifier: String {
        case showMatchPlayerDetails
        case unwindToHistory
    }
    
}
