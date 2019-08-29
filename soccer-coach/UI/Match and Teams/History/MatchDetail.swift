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
    
    
    // MARK: - Properties
        
    var homeTeamDataSource: UITableViewDiffableDataSource<Section, SoccerPlayer>? = nil
    var awayTeamDataSource: UITableViewDiffableDataSource<Section, SoccerPlayer>? = nil
    var homeCurrentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>? = nil
    var awayCurrentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>? = nil
    var match: Match?
    var selectedPlayer: SoccerPlayer? = nil
    var playerTeamType: TeamType = .home
    var homePlayers = [SoccerPlayer]()
    var awayPlayers = [SoccerPlayer]()
    
    var matchStats: MatchStats {
        return MatchStats(match: match)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let match = match else { return }
        title = match.summary
        homeSectionHeaderTitleLabel.text = match.homeTeam?.name
        awaySectionHeaderTitleLabel.text = match.awayTeam?.name
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
    
    
    func configureDataSource() {
        homeTeamDataSource = UITableViewDiffableDataSource<Section, SoccerPlayer>(tableView: homeTableView, cellProvider: { tableView, indexPath, player -> UITableViewCell? in
            guard let match = self.match else { return nil }
            let cell = tableView.dequeueReusableCell(withIdentifier: PlayerDetailCell.reuseIdentifier, for: indexPath) as! PlayerDetailCell
            let playingTimes = match.homePlayingTime?.filter { $0.player == player }.compactMap { $0 } ?? []
            let playerMatchStats = PlayerMatchStats(player: player, playingTimes: playingTimes, match: match)
            cell.configure(with: playerMatchStats)
            cell.accessoryType = .disclosureIndicator
            return cell
        })
        awayTeamDataSource = UITableViewDiffableDataSource<Section, SoccerPlayer>(tableView: awayTableView, cellProvider: { tableView, indexPath, player -> UITableViewCell? in
            guard let match = self.match else { return nil }
            let cell = tableView.dequeueReusableCell(withIdentifier: PlayerDetailCell.reuseIdentifier, for: indexPath) as! PlayerDetailCell
            let playingTimes = match.awayPlayingTime?.filter { $0.player == player }.compactMap { $0 } ?? []
            let playerMatchStats = PlayerMatchStats(player: player, playingTimes: playingTimes, match: match)
            cell.configure(with: playerMatchStats)
            cell.accessoryType = .disclosureIndicator
            return cell
        })
        updateTableUI()
    }
    
    func updateTableUI(animated: Bool = true) {
        DispatchQueue.main.async {
            guard let homeTeamDataSource = self.homeTeamDataSource, let awayTeamDataSource = self.awayTeamDataSource else { return }
            guard let match = self.match else { return }
            self.homeCurrentSnapshot = NSDiffableDataSourceSnapshot<Section, SoccerPlayer>()
            self.homeCurrentSnapshot?.appendSections([.home])
            self.homePlayers = match.homeTeam?.players.sorted { playerOne, playerTwo -> Bool in
                let playingTimesOne = match.homePlayingTime?.filter { $0.player == playerOne }.compactMap { $0 } ?? []
                let playingTimesTwo = match.homePlayingTime?.filter { $0.player == playerTwo }.compactMap { $0 } ?? []
                let statsOne = PlayerMatchStats(player: playerOne, playingTimes: playingTimesOne, match: match)
                let statsTwo = PlayerMatchStats(player: playerTwo, playingTimes: playingTimesTwo, match: match)
                return statsOne.minutesPlayed > statsTwo.minutesPlayed
            } ?? []
            self.awayPlayers = match.awayTeam?.players.sorted { playerOne, playerTwo -> Bool in
                let playingTimesOne = match.awayPlayingTime?.filter { $0.player == playerOne }.compactMap { $0 } ?? []
                let playingTimesTwo = match.awayPlayingTime?.filter { $0.player == playerTwo }.compactMap { $0 } ?? []
                let statsOne = PlayerMatchStats(player: playerOne, playingTimes: playingTimesOne, match: match)
                let statsTwo = PlayerMatchStats(player: playerTwo, playingTimes: playingTimesTwo, match: match)
                return statsOne.minutesPlayed > statsTwo.minutesPlayed
            } ?? []

            self.homeCurrentSnapshot?.appendItems(self.homePlayers)
            self.awayCurrentSnapshot = NSDiffableDataSourceSnapshot<Section, SoccerPlayer>()
            self.awayCurrentSnapshot?.appendSections([.away])
            self.awayCurrentSnapshot?.appendItems(self.awayPlayers)
            guard let homeCurrentSnapshot = self.homeCurrentSnapshot, let awayCurrentSnapshot = self.awayCurrentSnapshot else { return }
            homeTeamDataSource.apply(homeCurrentSnapshot, animatingDifferences: animated)
            awayTeamDataSource.apply(awayCurrentSnapshot, animatingDifferences: animated)
        }
    }
    
}


extension MatchDetail: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == homeTableView {
            selectedPlayer = homePlayers[indexPath.row]
            playerTeamType = .home
        }
        if tableView == awayTableView {
            selectedPlayer = awayPlayers[indexPath.row]
            playerTeamType = .away
        }
        performSegue(withIdentifier: .showMatchPlayerDetails, sender: nil)
    }
    
}


// MARK: - Segue handling

extension MatchDetail: SegueHandling {
    
    enum SegueIdentifier: String {
        case showMatchPlayerDetails
    }
    
}
