//
//  FirstViewController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit
import Combine

class SoccerTeamCollection: UIViewController {
    
    // MARK: - Enums
    
    enum Section: Int, CaseIterable {
        case frontLine, attackingMid, holdingMid, backLine, goalie
        
        var positions: [Position] {
            switch self {
            case .frontLine:
                return [.eleven, .nine, .seven]
            case .attackingMid:
                return [.ten, .eight]
            case .holdingMid:
                return [.six]
            case .backLine:
                return [.three, .five, .four, .two]
            case .goalie:
                return [.one]
            }
        }
        
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var shotRatingView: UIView!
    @IBOutlet weak var shotDescriptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var addAssistButton: RoundedButton!
    @IBOutlet weak var assistTableView: UITableView!
    @IBOutlet weak var shotViewTitleLabel: UILabel!
    @IBOutlet weak var shotDescriptionTextField: UITextField!
    @IBOutlet weak var addStatButton: UIButton!
    
    // MARK: - Properties
    
    var dataSource: UICollectionViewDiffableDataSource<Section, SoccerPlayer>? = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>? = nil
    var selectedPlayer: SoccerPlayer?
    var temporaryShot: TemporaryShot?
    var assistee: SoccerPlayer?
    var minuteTimeStamp: Int = 0
    let cellIdentifier = "cell"
    var currentMatch: Match? {
        didSet {
            resetPlayers()
            updateSnapshot()
            DispatchQueue.main.async {
                self.addStatButton.isHidden = self.currentMatch == nil                
            }
        }
    }
    var currentTeamType: TeamType = .home {
        didSet {
            updateSnapshot()
        }
    }
    var halfHasStartedSubscriber: AnyCancellable?
    var currentMatchSubscriber: AnyCancellable?
    var teamTypeSubscriber: AnyCancellable?

    var homeActivePlayersPerSection: [Section: [SoccerPlayer]] = [:]
    var awayActivePlayersPerSection: [Section: [SoccerPlayer]] = [:]
    var fillerPlayers = [SoccerPlayer]()
    
    var activePlayersPerSection: [Section: [SoccerPlayer]] {
        switch currentTeamType {
        case .home:
            return homeActivePlayersPerSection
        case .away:
            return awayActivePlayersPerSection
        }
    }
    var homeActivePlayers: [SoccerPlayer] {
        return homeActivePlayersPerSection.values.flatMap { $0 }.filter  { !$0.isFiller }
    }
    var awayActivePlayers: [SoccerPlayer] {
        return awayActivePlayersPerSection.values.flatMap { $0 }.filter  { !$0.isFiller }
    }
    var allActivePlayers: [SoccerPlayer] {
        return activePlayersPerSection.values.flatMap { $0 }
    }
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(ActivePlayerCell.nib(), forCellWithReuseIdentifier: ActivePlayerCell.reuseIdentifier)
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
        configureFillerData()
        configureSubscribers()
        assistTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureCollectionViewLayout()
        configureDataSource()
        shotRatingView.layer.cornerRadius = 8
        shotRatingView.clipsToBounds = true
        let value = Int(ratingSlider.value * 100)
        ratingLabel.text = "\(value)"
        shotDescriptionLabel.text = value.shotRatingDescription()
    }
    
    
    // MARK: = Actions
    
    @IBAction func hideShowButtonTapped() {
        let displayMode: UISplitViewController.DisplayMode = splitViewController?.preferredDisplayMode == .primaryHidden ? .automatic : .primaryHidden
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            self.splitViewController?.preferredDisplayMode = displayMode
        }, completion: nil)
    }
    
    
    @IBAction func ratingSliderValueChanged() {
        let value = Int(ratingSlider.value * 100)
        ratingLabel.text = "\(value)"
        shotDescriptionLabel.text = value.shotRatingDescription()
    }
    
    @IBAction func shotRatingSubmitButtonTaped() {
        UIView.animate(withDuration: 0.5, animations: {
            self.shotRatingView.alpha = 0.0
        }) { _ in
            guard let temporaryShot = self.temporaryShot, let match = self.currentMatch else { return }
            self.showMinuteAlert() {
                PlayingTimeController.shared.addShot(to: temporaryShot.player, match: match, teamType: self.currentTeamType, rating: Int(self.ratingSlider.value * 100), onTarget: temporaryShot.onTarget, isGoal: temporaryShot.isGoal, description: self.shotDescriptionTextField.text, timeStamp: self.minuteTimeStamp, assistee: self.assistee)
            }
            self.resetShotDetailView()
        }
    }
    
    @IBSegueAction func presentPlayerDetails(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UIViewController? {
        guard let player = selectedPlayer, let match = currentMatch else { return nil }
        let playingTime = PlayingTimeController.shared.playingTimes(for: player, match: match, teamType: currentTeamType)
        let playerMatchStats = PlayerMatchStats(player: player, playingTimes: playingTime, match: match)
        return CurrentMatchPlayerDetails(coder: coder, playerMatchStats: playerMatchStats)
    }
    
    @IBAction func addAssistButtonTapped() {
        UIView.animate(withDuration: 0.5) {
            self.assistTableView.alpha = 1.0
        }
        assistTableView.reloadData()
    }
    
    @IBAction func cancelShotDetailTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.shotRatingView.alpha = 0.0
        }
        resetShotDetailView()
    }
    
    @IBAction func generalStatButtonTapped() {
        showAddStatAlert(for: nil, cell: nil, section: .goalie)
    }
    
}


// MARK: - Private functions

private extension SoccerTeamCollection {
    
    // MARK: - DataSource
    
    func configureFillerData() {
        let savedFillerPlayers = UserDefaults.standard.bool(forKey: Keys.savedFillerPlayers)
        if !savedFillerPlayers {
            for _ in 0..<11 {
                _ = SoccerPlayerController.shared.createPlayer(with: Keys.fillerPlayerName, isFiller: true)
            }
            UserDefaults.standard.set(true, forKey: Keys.savedFillerPlayers)
        }
        fillerPlayers = SoccerPlayerController.shared.fetchAllFillerPlayers()
        resetPlayers()
    }
    
    func resetPlayers() {
        var players = fillerPlayers
        for section in Section.allCases {
            var playersForSection = [SoccerPlayer]()
            for position in section.positions {
                guard let player = players.first else { continue }
                player.name = position.name
                playersForSection.append(player)
                players.removeFirst()
            }
            homeActivePlayersPerSection[section] = playersForSection
        }
        awayActivePlayersPerSection = homeActivePlayersPerSection
    }
    
    func configureCollectionViewLayout() {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let collectionSection = Section(rawValue: sectionIndex) else { return nil }
            
            let columns = self.activePlayersPerSection[collectionSection]?.count ?? 0
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                                                  heightDimension: .fractionalHeight(0.9))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(0.2))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        collectionView.collectionViewLayout = layout
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, SoccerPlayer>(collectionView: collectionView, cellProvider: { collectionView, indexPath, player -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(for: indexPath) as ActivePlayerCell
            cell.configure(with: player)
            cell.clipsToBounds = true
            return cell
        })
        updateSnapshot()
    }
    
    func updateSnapshot() {
        guard let dataSource = dataSource else { return }
        DispatchQueue.main.async {
            self.currentSnapshot = NSDiffableDataSourceSnapshot<Section, SoccerPlayer>()
            guard var currentSnapshot = self.currentSnapshot else { return }
            Section.allCases.forEach {
                currentSnapshot.appendSections([$0])
                currentSnapshot.appendItems(self.activePlayersPerSection[$0] ?? [])
            }
            dataSource.apply(currentSnapshot, animatingDifferences: true)
        }
    }
    
    
    // MARK: - Helpers
    
    func activePlayersContains(_ player: SoccerPlayer) -> Bool {
        return allActivePlayers.contains(player)
    }
    
    func showShotRatingView() {
        guard let tempShot = self.temporaryShot else { return }
        addAssistButton.isHidden = !tempShot.isGoal || tempShot.player == nil
        shotRatingView.transform = CGAffineTransform(scaleX: 0.10, y: 0.10)
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            self.shotRatingView.transform = .identity
            self.shotRatingView.alpha = 1.0
        })
    }
    
    func resetShotDetailView() {
        temporaryShot = nil
        assistee = nil
        shotDescriptionTextField.text = nil
        self.addAssistButton.setTitle("Add Assist", for: .normal)
    }
    
    func position(for player: SoccerPlayer, teamType: TeamType) -> Position? {
        var playerArrays = [[SoccerPlayer]]()
        switch teamType {
        case .home:
            let sortedPlayersPerSection = homeActivePlayersPerSection.sorted(by: { $0.key.rawValue < $1.key.rawValue })
            playerArrays = sortedPlayersPerSection.map { $0.value }
        case .away:
            let sortedPlayersPerSection = awayActivePlayersPerSection.sorted(by: { $0.key.rawValue < $1.key.rawValue })
            playerArrays = sortedPlayersPerSection.map { $0.value }
        }
        let sectionIndex = playerArrays.firstIndex { $0.contains(player) }
        guard let section = sectionIndex else { return nil }
        guard let rowIndex = playerArrays[section].firstIndex(of: player) else { return nil }
        return position(for: IndexPath(row: rowIndex, section: section))
    }
    
    func position(for indexPath: IndexPath) -> Position? {
        guard let section = Section(rawValue: indexPath.section) else { return nil }
        return section.positions[indexPath.row]
    }
    
    func showMinuteAlert(_ completion: (() -> Void)? = nil) {
        guard App.sharedCore.state.matchState.halfStarted else { return }
        let alert = UIAlertController(title: "Add minute", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "25"
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            guard let text = alert.textFields?.first?.text else { return }
            self.minuteTimeStamp = Int(text) ?? 0
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
}


// MARK: - CollectionView delegate

extension SoccerTeamCollection: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ActivePlayerCell, let section = Section(rawValue: indexPath.section) else { return }
        selectedPlayer = cell.player
        showAddStatAlert(for: cell.player, cell: cell, section: section)
        
    }
    
    func showAddStatAlert(for player: SoccerPlayer?, cell: ActivePlayerCell?, section: Section) {
        guard let match = currentMatch else { return }
        let goal = UIAlertAction(title: "Goal", style: .default) { _ in
            self.temporaryShot = TemporaryShot(player: self.selectedPlayer, onTarget: true, isGoal: true)
            self.showShotRatingView()
        }
        let shotOnTarget = UIAlertAction(title: "Shot on Target", style: .default) { _ in
            self.temporaryShot = TemporaryShot(player: self.selectedPlayer, onTarget: true, isGoal: false)
            self.showShotRatingView()
        }
        let shotOffTarget = UIAlertAction(title: "Shot off Target", style: .default) { _ in
            self.temporaryShot = TemporaryShot(player: self.selectedPlayer, onTarget: false, isGoal: false)
            self.showShotRatingView()
        }
        let turnover = UIAlertAction(title: "Turnover", style: .default) { _ in
            self.presentTurnoverAlert(player: self.selectedPlayer, match: match)
        }
        let foul = UIAlertAction(title: "Foul", style: .default) { _ in
            self.presentFoulAlert(player: self.selectedPlayer, match: match)
        }
        let yellowCard = UIAlertAction(title: "Yellow Card", style: .default) { _ in
            self.showMinuteAlert() {
                PlayingTimeController.shared.addCard(to: self.selectedPlayer, match: match, teamType: self.currentTeamType, cardType: .yellow, timeStamp: self.minuteTimeStamp)
            }
        }
        let redCard = UIAlertAction(title: "Red Card", style: .default) { _ in
            self.showMinuteAlert() {
                PlayingTimeController.shared.addCard(to: self.selectedPlayer, match: match, teamType: self.currentTeamType, cardType: .red, timeStamp: self.minuteTimeStamp)
                if let player = self.selectedPlayer {
                    PlayingTimeController.shared.endPlayingTime(for: player, match: match, teamType: self.currentTeamType, endTime: self.minuteTimeStamp)
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        var actions = [goal, shotOnTarget, shotOffTarget, turnover, foul, yellowCard, redCard, cancel]
        
        if section == .goalie {
            let save = UIAlertAction(title: "Save", style: .default) { _ in
                self.showMinuteAlert() {
                    PlayingTimeController.shared.addSave(to: player, match: match, teamType: self.currentTeamType, timeStamp: self.minuteTimeStamp)
                }
            }
            actions.append(save)
        }
        let details = UIAlertAction(title: "View Player Stats", style: .default) { _ in
            self.performSegue(withIdentifier: .presentPlayerDetails, sender: nil)
        }
        actions.append(details)
        
        if let cell = cell {
            let alertController = UIAlertController(title: "Player Actions", message: nil, preferredStyle: .actionSheet)
            for action in actions {
                alertController.addAction(action)
            }
            let rect = view.convert(cell.nameLabel.bounds, to: view)
            alertController.popoverPresentationController?.sourceView = cell.nameLabel
            alertController.popoverPresentationController?.sourceRect = rect
            alertController.view.tintColor = .label
            present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Player Actions", message: nil, preferredStyle: .alert)
            for action in actions {
                alertController.addAction(action)
            }
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentTurnoverAlert(player: SoccerPlayer?, match: Match) {
        let alert = UIAlertController(title: "Turnover Type", message: nil, preferredStyle: .alert)
        let badPass = UIAlertAction(title: "Bad Pass", style: .default) { _ in
            self.showMinuteAlert() {
                PlayingTimeController.shared.addTurnover(to: player, match: match, teamType: self.currentTeamType, badPass: true, badTouch: false, timeStamp: self.minuteTimeStamp)
            }
        }
        let badTouch = UIAlertAction(title: "Bad Touch", style: .default) { _ in
            self.showMinuteAlert() {
                PlayingTimeController.shared.addTurnover(to: player, match: match, teamType: self.currentTeamType, badPass: false, badTouch: true, timeStamp: self.minuteTimeStamp)
            }
        }
        alert.addAction(badPass)
        alert.addAction(badTouch)
        alert.view.tintColor = .label
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentFoulAlert(player: SoccerPlayer?, match: Match) {
        let alert = UIAlertController(title: "Foul Type", message: nil, preferredStyle: .alert)
        let offsides = UIAlertAction(title: "Offsides", style: .default) { _ in
            self.showMinuteAlert() {
                PlayingTimeController.shared.addFoul(to: player, match: match, teamType: self.currentTeamType, isOffsides: true, timeStamp: self.minuteTimeStamp)
            }
        }
        let common = UIAlertAction(title: "Common Foul", style: .default) { _ in
            self.showMinuteAlert() {
                PlayingTimeController.shared.addFoul(to: player, match: match, teamType: self.currentTeamType, isOffsides: false, timeStamp: self.minuteTimeStamp)
            }
        }
        alert.addAction(offsides)
        alert.addAction(common)
        alert.view.tintColor = .label
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK: - Drag delegate

extension SoccerTeamCollection: UICollectionViewDragDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        guard let section = Section(rawValue: indexPath.section), let player = activePlayersPerSection[section]?[indexPath.row], Int(player.name) == nil  else { return [] }
        let itemProvider = NSItemProvider(object: player)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = player
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ActivePlayerCell else { return nil }
        let previewParameters = UIDragPreviewParameters()
        previewParameters.backgroundColor = .clear
        let path = UIBezierPath(roundedRect: cell.visualEffectView.frame, cornerRadius: cell.visualEffectView.frame.width / 2)
        previewParameters.visiblePath = path
        return previewParameters
    }
    
}


// MARK: - Drop delegate

extension SoccerTeamCollection: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            guard let movingPlayer = item.dragItem.localObject as? SoccerPlayer else { continue }
            let insertionIndexPath = destinationIndexPath
            guard let section = Section(rawValue: insertionIndexPath.section) else { continue }
            guard let playersForSection = activePlayersPerSection[section] else { continue }
           
            // When moving an active player from one position to another
            if activePlayersContains(movingPlayer) {
                if let sourceIndexPath = item.sourceIndexPath, let sourceSection = Section(rawValue: sourceIndexPath.section), let destinationPlayer = activePlayersPerSection[section]?[insertionIndexPath.row], let match = currentMatch {
                    switch currentTeamType {
                    case .home:
                        guard let insertionPosition = self.position(for: insertionIndexPath), let sourcePosition = self.position(for: sourceIndexPath) else { return }
                        homeActivePlayersPerSection[section]?[insertionIndexPath.row] = movingPlayer
                        homeActivePlayersPerSection[sourceSection]?[sourceIndexPath.row] = destinationPlayer
                        showMinuteAlert() {
                            PlayingTimeController.shared.endPlayingTime(for: movingPlayer, match: match, teamType: self.currentTeamType, endTime: self.minuteTimeStamp)
                            PlayingTimeController.shared.addPlayingTime(to: match, for: movingPlayer, teamType: self.currentTeamType, position: insertionPosition, startTime: self.minuteTimeStamp)
                            PlayingTimeController.shared.endPlayingTime(for: destinationPlayer, match: match, teamType: self.currentTeamType, endTime: self.minuteTimeStamp)
                            PlayingTimeController.shared.addPlayingTime(to: match, for: destinationPlayer, teamType: self.currentTeamType, position: sourcePosition, startTime: self.minuteTimeStamp)
                        }
                        
                    case .away:
                        guard let insertionPosition = self.position(for: insertionIndexPath), let sourcePosition = self.position(for: sourceIndexPath) else { return }
                        awayActivePlayersPerSection[section]?[insertionIndexPath.row] = movingPlayer
                        awayActivePlayersPerSection[sourceSection]?[sourceIndexPath.row] = destinationPlayer
                        showMinuteAlert() {
                            PlayingTimeController.shared.endPlayingTime(for: movingPlayer, match: match, teamType: self.currentTeamType, endTime: self.minuteTimeStamp)
                            PlayingTimeController.shared.addPlayingTime(to: match, for: movingPlayer, teamType: self.currentTeamType, position: insertionPosition, startTime: self.minuteTimeStamp)
                            PlayingTimeController.shared.endPlayingTime(for: destinationPlayer, match: match, teamType: self.currentTeamType, endTime: self.minuteTimeStamp)
                            PlayingTimeController.shared.addPlayingTime(to: match, for: destinationPlayer, teamType: self.currentTeamType, position: sourcePosition, startTime: self.minuteTimeStamp)
                        }
                    }
                }
            
            // When adding a new player
            } else if playersForSection.count + 1 >= insertionIndexPath.row, let destinationPlayer = activePlayersPerSection[section]?[insertionIndexPath.row] {
                switch currentTeamType {
                case .home:
                    homeActivePlayersPerSection[section]?[insertionIndexPath.row] = movingPlayer
                case .away:
                    awayActivePlayersPerSection[section]?[insertionIndexPath.row] = movingPlayer
                }
                destinationPlayer.isActive = false
                guard let match = currentMatch, let position = self.position(for: insertionIndexPath) else { return }
                self.showMinuteAlert() {
                    PlayingTimeController.shared.addPlayingTime(to: match, for: movingPlayer, teamType: self.currentTeamType, position: position, startTime: self.minuteTimeStamp)
                    PlayingTimeController.shared.endPlayingTime(for: destinationPlayer, match: match, teamType: self.currentTeamType, endTime: self.minuteTimeStamp)
                }
            }
            movingPlayer.isActive = true
            updateSnapshot()
        }
    }
    
}


// MARK: - Segue handling

extension SoccerTeamCollection: SegueHandling {
    
    enum SegueIdentifier: String {
        case presentPlayerDetails
    }
    
}


// MARK: - Subscribers

extension SoccerTeamCollection: Subscriberable {
    
    func configureSubscribers() {
        let state = App.sharedCore.state
        currentMatchSubscriber = state.matchState.$currentMatch
            .assign(to: \.currentMatch, on: self)
        teamTypeSubscriber = state.matchState.$selectedTeamType
            .assign(to: \.currentTeamType, on: self)
        
        halfHasStartedSubscriber = state.matchState.$halfStarted
        .sink(receiveValue: { hasStarted in
            guard let match = self.currentMatch else { return }
            if !hasStarted {
                let endTime = (match.half + 1) * match.halfLength
                for player in self.homeActivePlayers {
                    PlayingTimeController.shared.endPlayingTime(for: player, match: match, teamType: .home, endTime: Int(endTime))
                }
                for player in self.awayActivePlayers {
                    PlayingTimeController.shared.endPlayingTime(for: player, match: match, teamType: .away, endTime: Int(endTime))
                }
            } else {
                DispatchQueue.main.async {
                    let startTime = match.half * match.halfLength
                    PlayingTimeController.shared.addGeneralTeamPlayingTime(to: match, teamType: .home)
                    PlayingTimeController.shared.addGeneralTeamPlayingTime(to: match, teamType: .away)
                    for player in self.homeActivePlayers {
                        guard let position = self.position(for: player, teamType: .home) else { continue }
                        PlayingTimeController.shared.addPlayingTime(to: match, for: player, teamType: .home, position: position, startTime: Int(startTime))
                    }
                    for player in self.awayActivePlayers {
                        guard let position = self.position(for: player, teamType: .away) else { continue }
                        PlayingTimeController.shared.addPlayingTime(to: match, for: player, teamType: .away, position: position, startTime: Int(startTime))
                    }
                }
            }
        })
    }
    
}


// MARK: - Tableview data source

extension SoccerTeamCollection: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentTeamType {
        case .home:
            return homeActivePlayers.count
        case .away:
            return awayActivePlayers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        switch currentTeamType {
        case .home:
            let player = homeActivePlayers[indexPath.row]
            cell.textLabel?.text = player.name
        case .away:
            let player = awayActivePlayers[indexPath.row]
            cell.textLabel?.text = player.name
        }
        return cell
    }
    
}


// MARK: - Tableview delegate

extension SoccerTeamCollection: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch currentTeamType {
        case .home:
            assistee = homeActivePlayers[indexPath.row]
        case .away:
            assistee = awayActivePlayers[indexPath.row]
        }
        if assistee == temporaryShot?.player {
            assistee = nil
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.assistTableView.alpha = 0.0
            self.shotViewTitleLabel.text = "Shot Difficulty Rating"
            guard let assistee = self.assistee else { return }
            self.addAssistButton.setTitle("Assist: \(assistee.name)", for: .normal)
        }
    }
}
