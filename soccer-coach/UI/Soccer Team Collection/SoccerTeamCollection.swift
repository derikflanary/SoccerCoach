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
    @IBOutlet weak var shotDescriptionTextView: UITextView!
    @IBOutlet weak var addDescriptionButton: RoundedButton!
    @IBOutlet weak var cancelSaveStackView: UIStackView!
    @IBOutlet weak var saveShotDetailButton: UIButton!
    
    
    // MARK: - Properties
    
    var dataSource: UICollectionViewDiffableDataSource<Section, SoccerPlayer>? = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>? = nil
    var selectedPlayer: SoccerPlayer?
    var temporaryShot: TemporaryShot?
    var assistee: SoccerPlayer?
    let cellIdentifier = "cell"
    var currentMatch: Match? {
        didSet {
            resetPlayers()
            updateSnapshot()
        }
    }
    var currentTeamType: TeamType = .home {
        didSet {
            updateSnapshot()
        }
    }
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
        return homeActivePlayersPerSection.values.flatMap { $0 }.filter  { $0.name != Keys.fillerPlayerName }
    }
    var awayActivePlayers: [SoccerPlayer] {
        return awayActivePlayersPerSection.values.flatMap { $0 }.filter  { $0.name != Keys.fillerPlayerName }
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
            PlayingTimeController.shared.addShot(to: temporaryShot.player, match: match, teamType: self.currentTeamType, rating: Int(self.ratingSlider.value * 100), onTarget: temporaryShot.onTarget, isGoal: temporaryShot.isGoal, description: self.shotDescriptionTextView.text, assistee: self.assistee)
            self.temporaryShot = nil
            self.assistee = nil
            self.addAssistButton.setTitle("Add Assist", for: .normal)
            self.shotDescriptionTextView.text = ""
            self.shotDescriptionTextView.isHidden = true
            self.addDescriptionButton.isHidden = false
        }
    }
    
    @IBSegueAction func presentPlayerDetails(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UIViewController? {
        guard let player = selectedPlayer, let match = currentMatch else { return nil }
        let playingTime = PlayingTimeController.shared.playingTimes(for: player, match: match, teamType: currentTeamType)
        let playerMatchStats = PlayerMatchStats(player: player, playingTimes: playingTime)
        return CurrentMatchPlayerDetails(coder: coder, playerMatchStats: playerMatchStats)
    }
    
    @IBAction func addAssistButtonTapped() {
        self.saveShotDetailButton.isHidden = true
        UIView.animate(withDuration: 0.5) {
            self.assistTableView.alpha = 1.0
            self.cancelSaveStackView.isHidden = false
        }
        assistTableView.reloadData()
    }
    
    @IBAction func addDescriptionButtonTapped() {
        UIView.animate(withDuration: 0.5) {
            self.shotDescriptionTextView.alpha = 1.0
            self.cancelSaveStackView.isHidden = false
            self.saveShotDetailButton.isHidden = false
        }
    }
    
    @IBAction func saveShotDetailTapped(_ sender: Any) {
        if shotDescriptionTextView.alpha == 1.0 && shotDescriptionTextView.text != "" {
            addDescriptionButton.setTitle(shotDescriptionTextView.text, for: .normal)
        }
        hideSaveCancelViews()
    }
    
    @IBAction func cancelShotDetailTapped(_ sender: Any) {
        if shotDescriptionTextView.alpha == 1.0 {
            shotDescriptionTextView.text = ""
        }
        hideSaveCancelViews()
    }
    
    func hideSaveCancelViews() {
        UIView.animate(withDuration: 0.5, animations: {
            self.cancelSaveStackView.isHidden = true
            self.shotDescriptionTextView.alpha = 0.0
            self.assistTableView.alpha = 0.0
            self.addAssistButton.setTitle("Add Assist", for: .normal)
        }) { _ in
            self.saveShotDetailButton.isHidden = false
        }
    }
    
}


// MARK: - Private functions

private extension SoccerTeamCollection {
    
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
            guard let currentSnapshot = self.currentSnapshot else { return }
            Section.allCases.forEach {
                currentSnapshot.appendSections([$0])
                currentSnapshot.appendItems(self.activePlayersPerSection[$0] ?? [])
            }
            dataSource.apply(currentSnapshot, animatingDifferences: true)
        }
    }
    
    func activePlayersContains(_ player: SoccerPlayer) -> Bool {
        return allActivePlayers.contains(player)
    }
    
    func showShotRatingView() {
        guard let tempShot = self.temporaryShot else { return }
        shotDescriptionTextView.text = ""
        ratingSlider.setValue(0.5, animated: false)
        addAssistButton.isHidden = !tempShot.isGoal
        shotRatingView.transform = CGAffineTransform(scaleX: 0.10, y: 0.10)
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            self.shotRatingView.transform = .identity
            self.shotRatingView.alpha = 1.0
        })
    }
    
    func position(for indexPath: IndexPath) -> Position? {
        guard let section = Section(rawValue: indexPath.section) else { return nil }
        return section.positions[indexPath.row]
    }
    
}


// MARK: - CollectionView delegate

extension SoccerTeamCollection: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ActivePlayerCell else { return }
        guard let player = cell.player, let match = currentMatch else { return }
        selectedPlayer = player
        let goal = UIAlertAction(title: "Goal", style: .default) { _ in
            self.temporaryShot = TemporaryShot(player: player, onTarget: true, isGoal: true)
            self.showShotRatingView()
        }
        let shotOnTarget = UIAlertAction(title: "Shot on Target", style: .default) { _ in
            self.temporaryShot = TemporaryShot(player: player, onTarget: true, isGoal: false)
            self.showShotRatingView()
        }
        let shotOffTarget = UIAlertAction(title: "Shot off Target", style: .default) { _ in
            self.temporaryShot = TemporaryShot(player: player, onTarget: false, isGoal: false)
            self.showShotRatingView()
        }
        let turnover = UIAlertAction(title: "Turnover", style: .default) { _ in
            let alert = UIAlertController(title: "Turnover Type", message: nil, preferredStyle: .alert)
            let badPass = UIAlertAction(title: "Bad Pass", style: .default) { _ in
                PlayingTimeController.shared.addTurnover(to: player, match: match, teamType: self.currentTeamType, badPass: true, badTouch: false)
            }
            let badTouch = UIAlertAction(title: "Bad Touch", style: .default) { _ in
                PlayingTimeController.shared.addTurnover(to: player, match: match, teamType: self.currentTeamType, badPass: false, badTouch: true)
            }
            alert.addAction(badPass)
            alert.addAction(badTouch)
            alert.view.tintColor = .label
            self.present(alert, animated: true, completion: nil)
        }
        let foul = UIAlertAction(title: "Foul", style: .default) { _ in
            PlayingTimeController.shared.addFoul(to: player, match: match, teamType: self.currentTeamType)
        }
        let yellowCard = UIAlertAction(title: "Yellow Card", style: .default) { _ in
            PlayingTimeController.shared.addCard(to: player, match: match, teamType: self.currentTeamType, cardType: .yellow)
        }
        let redCard = UIAlertAction(title: "Red Card", style: .default) { _ in
            PlayingTimeController.shared.addCard(to: player, match: match, teamType: self.currentTeamType, cardType: .red)
            PlayingTimeController.shared.endPlayingTime(for: player, match: match, teamType: self.currentTeamType)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        var actions = [goal, shotOnTarget, shotOffTarget, turnover, foul, yellowCard, redCard, cancel]
        
        if let section = Section(rawValue: indexPath.section), section == .goalie {
            let save = UIAlertAction(title: "Save", style: .default) { _ in
                // TODO: Functionality for saves
            }
            actions.append(save)
        }
        let details = UIAlertAction(title: "View Player Stats", style: .default) { _ in
            self.performSegue(withIdentifier: .presentPlayerDetails, sender: nil)
        }
        actions.append(details)
        
        let alertController = UIAlertController(title: "Player Actions", message: nil, preferredStyle: .actionSheet)
        for action in actions {
            alertController.addAction(action)
        }
        
        let rect = view.convert(cell.nameLabel.bounds, to: view)
        alertController.popoverPresentationController?.sourceView = cell.nameLabel
        alertController.popoverPresentationController?.sourceRect = rect
        alertController.view.tintColor = .label
        present(alertController, animated: true, completion: nil)
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
            if activePlayersContains(movingPlayer) {
                if let sourceIndexPath = item.sourceIndexPath, let sourceSection = Section(rawValue: sourceIndexPath.section), let destinationPlayer = activePlayersPerSection[section]?[insertionIndexPath.row], let match = currentMatch {
                    switch currentTeamType {
                    case .home:
                        guard let insertionPosition = self.position(for: insertionIndexPath) else { return }
                        homeActivePlayersPerSection[section]?[insertionIndexPath.row] = movingPlayer
                        PlayingTimeController.shared.addPlayingTime(to: match, for: movingPlayer, teamType: currentTeamType, position: insertionPosition)
                        PlayingTimeController.shared.endPlayingTime(for: movingPlayer, match: match, teamType: currentTeamType)
                        
                        guard let sourcePosition = self.position(for: sourceIndexPath) else { return }
                        homeActivePlayersPerSection[sourceSection]?[sourceIndexPath.row] = destinationPlayer
                        PlayingTimeController.shared.addPlayingTime(to: match, for: destinationPlayer, teamType: currentTeamType, position: sourcePosition)
                        PlayingTimeController.shared.endPlayingTime(for: destinationPlayer, match: match, teamType: currentTeamType)
                    case .away:
                        guard let insertionPosition = self.position(for: insertionIndexPath) else { return }
                        awayActivePlayersPerSection[section]?[insertionIndexPath.row] = movingPlayer
                        PlayingTimeController.shared.addPlayingTime(to: match, for: movingPlayer, teamType: currentTeamType, position: insertionPosition)
                        PlayingTimeController.shared.endPlayingTime(for: movingPlayer, match: match, teamType: currentTeamType)
                        
                        guard let sourcePosition = self.position(for: sourceIndexPath) else { return }
                        awayActivePlayersPerSection[sourceSection]?[sourceIndexPath.row] = destinationPlayer
                        PlayingTimeController.shared.addPlayingTime(to: match, for: destinationPlayer, teamType: currentTeamType, position: sourcePosition)
                        PlayingTimeController.shared.endPlayingTime(for: destinationPlayer, match: match, teamType: currentTeamType)
                    }
                }
            } else if playersForSection.count + 1 >= insertionIndexPath.row, let destinationPlayer = activePlayersPerSection[section]?[insertionIndexPath.row] {
                switch currentTeamType {
                case .home:
                    homeActivePlayersPerSection[section]?[insertionIndexPath.row] = movingPlayer
                case .away:
                    awayActivePlayersPerSection[section]?[insertionIndexPath.row] = movingPlayer
                }
                destinationPlayer.isActive = false
                guard let match = currentMatch, let position = self.position(for: insertionIndexPath) else { return }
                PlayingTimeController.shared.addPlayingTime(to: match, for: movingPlayer, teamType: currentTeamType, position: position)
                PlayingTimeController.shared.endPlayingTime(for: destinationPlayer, match: match, teamType: currentTeamType)
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


extension SoccerTeamCollection: Subscriberable {
    
    func configureSubscribers() {
        let state = App.sharedCore.state
        currentMatchSubscriber = state.matchState.$currentMatch
            .assign(to: \.currentMatch, on: self)
        teamTypeSubscriber = state.matchState.$selectedTeamType
            .assign(to: \.currentTeamType, on: self)
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
