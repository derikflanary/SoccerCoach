//
//  SecondViewController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit
import Combine

class CurrentTeams: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamSegmentedControl: UISegmentedControl!
    @IBOutlet var emptyStateView: UIView!
    
    
    // MARK: - Properties
    
    var dataSource: UITableViewDiffableDataSource<TeamType, SoccerPlayer>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<TeamType, SoccerPlayer>! = nil
    let cellIdentifier = "cell"
    var currentSection = TeamType.home
    var selectedPlayer: SoccerPlayer?
    var currentMatchSubscriber: AnyCancellable?
    var currentMatch: Match? {
        didSet {
            updateTableUI()
        }
    }
    var currentTeam: Team? {
        switch currentSection {
        case .home:
            return currentMatch?.homeTeam
        case .away:
            return currentMatch?.awayTeam
        }
    }
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dragDelegate = self
        configDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSubscribers()
    }
    
    
    // MARK: - Actions
    
    @IBAction func teamSegmentedControlChanged(_ sender: UISegmentedControl) {
        currentSection = TeamType(rawValue: sender.selectedSegmentIndex) ?? .home
        App.sharedCore.fire(event: Selected(item: currentSection))
        updateTableUI()
    }
    
    @IBSegueAction func presentPlayerMatchDetails(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UIViewController? {
        guard let player = selectedPlayer, let match = currentMatch else { return nil }
        let playingTime = PlayingTimeController.shared.playingTimes(for: player, match: match, teamType: currentSection)
        let playerMatchStats = PlayerMatchStats(player: player, playingTimes: playingTime)
        return CurrentMatchPlayerDetails(coder: coder, playerMatchStats: playerMatchStats)
    }
    
}


// MARK: - Private functions

private extension CurrentTeams {
    
    func configDataSource() {
        self.dataSource = UITableViewDiffableDataSource<TeamType, SoccerPlayer>(tableView: tableView, cellProvider: { tableView, indexPath, player -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = player.name
            cell.detailTextLabel?.text = player.number
            cell.imageView?.image = player.isActive ? UIImage(systemName: "circle.fill") : nil
            return cell
        })
        updateTableUI()
    }
    
    func updateTableUI(animated: Bool = true) {
        DispatchQueue.main.async {
            self.currentSnapshot = NSDiffableDataSourceSnapshot<TeamType, SoccerPlayer>()
            self.currentSnapshot.appendSections([self.currentSection])
            self.tableView.backgroundView = self.currentMatch == nil ? self.emptyStateView : nil
            
            let filteredPlayers = self.currentTeam?.players.sorted(by: { (playerOne, playerTwo) -> Bool in
                if playerOne.isActive && playerTwo.isActive {
                    return playerOne.name < playerTwo.name
                }
                if !playerOne.isActive && !playerTwo.isActive {
                    return playerOne.name < playerTwo.name
                }
                return playerOne.isActive && !playerTwo.isActive
            })
            self.currentSnapshot.appendItems(filteredPlayers ?? [])
            self.dataSource.apply(self.currentSnapshot, animatingDifferences: animated)
        }
    }
    
}


// MARK: - Tableview delegate

extension CurrentTeams: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedPlayer = dataSource.itemIdentifier(for: indexPath)
        performSegue(withIdentifier: .presentPlayerDetails, sender: self)
    }
    
}


// MARK: - Drag delegate

extension CurrentTeams: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let player = dataSource.itemIdentifier(for: indexPath) else { return [] }
        let itemProvider = NSItemProvider(object: player)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = player
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        updateTableUI()
        tableView.reloadData()
    }
    
}


// MARK: - Segue handling

extension CurrentTeams: SegueHandling {
    
    enum SegueIdentifier: String {
        case presentPlayerDetails
    }
    
}


extension CurrentTeams: Subscriberable {
    
    func configureSubscribers() {
        let state = App.sharedCore.state
        currentMatchSubscriber = state.matchState.$currentMatch
            .assign(to: \.currentMatch, on: self)
    }
    
}
