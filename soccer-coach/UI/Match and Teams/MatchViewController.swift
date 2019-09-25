//
//  MatchViewController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/30/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit
import Combine

class MatchViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var halfSegmentedControl: UISegmentedControl!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var awayLabel: UILabel!
    @IBOutlet weak var homeGoalLabel: UILabel!
    @IBOutlet weak var awayGoalLabel: UILabel!
    @IBOutlet weak var createMatchButton: UIBarButtonItem!
    @IBOutlet weak var endMatchButton: UIBarButtonItem!
    @IBOutlet weak var beginHalfButton: UIBarButtonItem!
    @IBOutlet weak var endHalfButton: UIBarButtonItem!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var homeCornersLabel: UILabel!
    @IBOutlet weak var awayCornersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamSegmentedControl: UISegmentedControl!
    @IBOutlet var emptyStateView: UIView!
    
    
    // MARK: - Properties
    
    var dataSource: UITableViewDiffableDataSource<TeamType, SoccerPlayer>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<TeamType, SoccerPlayer>! = nil
    let cellIdentifier = "cell"
    var currentSection = TeamType.home
    var selectedPlayer: SoccerPlayer?
    var half: Half = .first
    var currentMatchSubscriber: AnyCancellable?
    var homeGoalSubscriber: AnyCancellable?
    var awayGoalSubscriber: AnyCancellable?
    var halfHasStartedSubscriber: AnyCancellable?
    var halfStarted = false
        
    var currentTeam: Team? {
        switch currentSection {
        case .home:
            return match?.homeTeam
        case .away:
            return match?.awayTeam
        }
    }
    var match: Match? {
        didSet {
            guard match != oldValue else { return }
            updateUI(with: match)
            updateTableUI()
        }
    }
    var homeGoals: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.homeGoalLabel.text = String(self.homeGoals)
            }
        }
    }
    var awayGoals: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.awayGoalLabel.text = String(self.homeGoals)
            }
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
    
    @IBSegueAction func presentPlayerDetails(_ coder: NSCoder) -> UIViewController? {
        guard let player = selectedPlayer, let match = match else { return nil }
        let playingTime = PlayingTimeController.shared.playingTimes(for: player, match: match, teamType: currentSection)
        let playerMatchStats = PlayerMatchStats(player: player, playingTimes: playingTime, match: match)
        return CurrentMatchPlayerDetails(coder: coder, playerMatchStats: playerMatchStats)
    }
        
    @IBAction func endHalfButtonTapped() {
        App.sharedCore.fire(event: HalfEnded(isMatchOver: half == .second))
        updateHalfSelected()
    }
    
    @IBAction func beginHalfButonTapped() {
        App.sharedCore.fire(event: HalfStarted())
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) { }
    
    @IBAction func homeCornersStepperChanged(_ sender: UIStepper) {
        homeCornersLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func awayCornersStepperChanged(_ sender: UIStepper) {
        awayCornersLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func endMatchTapped() {
        guard let match = match else { return }
        let alert = UIAlertController(title: "End Match?", message: "Are you sure you want to end and save this match?", preferredStyle: .alert)
        let save = UIAlertAction(title: "Save and End", style: .default) { _ in
            guard let homeCorners = Int64(self.homeCornersLabel.text ?? "0"), let awayCorners = Int64(self.awayCornersLabel.text ?? "0") else { return }
            MatchController.shared.end(match, homeCornerCount: homeCorners, awayCornerCount: awayCorners, homeScore: Int64(self.homeGoals), awayScore: Int64(self.awayGoals))
            App.sharedCore.fire(event: Selected<Match?>(item: nil))
        }
        let noSave = UIAlertAction(title: "End without Saving", style: .destructive) { _ in
            MatchController.shared.delete(match)
            App.sharedCore.fire(event: Selected<Match?>(item: nil))
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(save)
        alert.addAction(noSave)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
        MatchController.shared.save(match)
    }

}


// MARK: - Private functions

private extension MatchViewController {
    
    func updateUI(with match: Match?) {
        DispatchQueue.main.async {
            if match == nil {
                self.view.backgroundColor = UIColor(named: "emptyStateBackground")
                self.mainStackView.alpha = 0.2
                self.mainStackView.isUserInteractionEnabled = false
                self.halfSegmentedControl.alpha = 0.2
                self.halfSegmentedControl.isUserInteractionEnabled = false
                self.endMatchButton.isEnabled = false
                self.createMatchButton.isEnabled = true
                self.endHalfButton.isEnabled = false
                self.beginHalfButton.isEnabled = false
                self.teamSegmentedControl.alpha = 0.2
                self.teamSegmentedControl.isUserInteractionEnabled = false
            } else {
                self.view.backgroundColor = .systemBackground
                self.mainStackView.alpha = 1.0
                self.mainStackView.isUserInteractionEnabled = true
                self.halfSegmentedControl.alpha = 1.0
                self.halfSegmentedControl.isUserInteractionEnabled = true
                self.halfSegmentedControl.selectedSegmentIndex = 0
                self.endMatchButton.isEnabled = true
                self.createMatchButton.isEnabled = false
                self.homeLabel.text = match?.homeTeam?.name
                self.awayLabel.text = match?.awayTeam?.name
                self.beginHalfButton.isEnabled = true
                self.teamSegmentedControl.alpha = 1.0
                self.teamSegmentedControl.isUserInteractionEnabled = true
                self.teamSegmentedControl.setTitle(match?.homeTeam?.name, forSegmentAt: 0)
                self.teamSegmentedControl.setTitle(match?.awayTeam?.name, forSegmentAt: 1)
            }
        }
    }
    
    func showHalfNotOverAlert() {
        let alert = UIAlertController(title: "Half not over", message: "The current half has not yet reached its limit. Are you sure you want to end the current half and continue?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Yes", style: .default) { _ in
            self.updateHalfSelected()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.halfSegmentedControl.selectedSegmentIndex = self.half.rawValue
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
        
    func updateHalfSelected() {
        guard let selectedHalf = Half(rawValue: halfSegmentedControl.selectedSegmentIndex + 1), selectedHalf != .extra else { return }
        half = selectedHalf
        halfSegmentedControl.selectedSegmentIndex = half.rawValue
    }
    
}


// MARK: - Subscriberable

extension MatchViewController: Subscriberable {
    
    func configureSubscribers() {
        let state = App.sharedCore.state
        currentMatchSubscriber = state.matchState.$currentMatch
            .assign(to: \.match, on: self)
        
        homeGoalSubscriber = state.matchState.$homeGoals
            .assign(to: \.homeGoals, on: self)
        
        awayGoalSubscriber = state.matchState.$awayGoals
            .assign(to: \.awayGoals, on: self)
        
        halfHasStartedSubscriber = state.matchState.$halfStarted
        .sink(receiveValue: { halfStarted in
            DispatchQueue.main.async {
                if let match = self.match, match.isOver {
                    self.beginHalfButton.isEnabled = false
                    self.endHalfButton.isEnabled = false
                } else if self.match == nil {
                    self.beginHalfButton.isEnabled = false
                    self.endHalfButton.isEnabled = false
                } else {
                    self.beginHalfButton.isEnabled = !halfStarted
                    self.endHalfButton.isEnabled = halfStarted
                }
            }
        })
    }
    
}


// MARK: - Tableview datasource

private extension MatchViewController {
    
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
            self.tableView.backgroundView = self.match == nil ? self.emptyStateView : nil
            
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

extension MatchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedPlayer = dataSource.itemIdentifier(for: indexPath)
        performSegue(withIdentifier: .presentPlayerDetails, sender: self)
    }
    
}


// MARK: - Drag delegate

extension MatchViewController: UITableViewDragDelegate {
    
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

extension MatchViewController: SegueHandling {
    
    enum SegueIdentifier: String {
        case presentPlayerDetails
    }
    
}
