//
//  FirstViewController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class SoccerTeamCollection: UIViewController {
    
    // MARK: - Enums
    
    enum Section: Int, CaseIterable {
        case frontLine, attackingMid, holdingMid, backLine, goalie
    }

    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: - Properties
    
    var dataSource: UICollectionViewDiffableDataSource<Section, SoccerPlayer>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>! = nil
    var activePlayersPerSection: [Section: [SoccerPlayer]] = [:]
    var masterWidthFraction: CGFloat? = nil
   
    var allActivePlayers: [SoccerPlayer] {
        return activePlayersPerSection.values.flatMap { $0 }
    }
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(ActivePlayerCell.nib(), forCellWithReuseIdentifier: ActivePlayerCell.reuseIdentifier)
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
        
        for section in Section.allCases {
            switch section {
            case .goalie:
                activePlayersPerSection[section] = [SoccerPlayer(name: "🏃🏻‍♀️")]
            case .backLine:
                activePlayersPerSection[section] = [SoccerPlayer(name: "🏃🏻‍♀️"), SoccerPlayer(name: "🏃🏻‍♀️"), SoccerPlayer(name: "🏃🏻‍♀️"), SoccerPlayer(name: "🏃🏻‍♀️")]
            case .holdingMid:
                activePlayersPerSection[section] = [SoccerPlayer(name: "🏃🏻‍♀️")]
            case .attackingMid:
                activePlayersPerSection[section] = [SoccerPlayer(name: "🏃🏻‍♀️"), SoccerPlayer(name: "🏃🏻‍♀️")]
            case .frontLine:
                activePlayersPerSection[section] = [SoccerPlayer(name: "🏃🏻‍♀️"), SoccerPlayer(name: "🏃🏻‍♀️"), SoccerPlayer(name: "🏃🏻‍♀️")]
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureCollectionViewLayout()
        configureDataSource()
    }

    
    // MARK: = Actions
    
    @IBAction func hideShowButtonTapped() {
        let displayMode: UISplitViewController.DisplayMode = splitViewController?.preferredDisplayMode == .primaryHidden ? .automatic : .primaryHidden
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            self.splitViewController?.preferredDisplayMode = displayMode
        }, completion: nil)
    }
    
}


// MARK: - Private functions

private extension SoccerTeamCollection {
    
    func configureCollectionViewLayout() {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let collectionSection = Section(rawValue: sectionIndex) else { return nil }
            
            let columns = self.activePlayersPerSection[collectionSection]?.count ?? 0
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                                                  heightDimension: .fractionalHeight(0.9))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8)
            
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
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, SoccerPlayer>()
        Section.allCases.forEach {
            currentSnapshot.appendSections([$0])
            currentSnapshot.appendItems(activePlayersPerSection[$0] ?? [])
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    func activePlayersContains(_ player: SoccerPlayer) -> Bool {
        return allActivePlayers.contains(player)
    }
    
}


// MARK: - CollectionView delegate

extension SoccerTeamCollection: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ActivePlayerCell else { return }
        let goal = UIAlertAction(title: "Goal", style: .default) { _ in
          
        }
        let shotOnTarget = UIAlertAction(title: "Shot on Target", style: .default) { _ in
            
        }
        let shotOffTarget = UIAlertAction(title: "Shot off Target", style: .default) { _ in
        
        }
        let assist = UIAlertAction(title: "Assist", style: .default) { _ in
            
        }
        let yellowCard = UIAlertAction(title: "Yellow Card", style: .default) { _ in
            
        }
        let redCard = UIAlertAction(title: "Red Card", style: .default) { _ in
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        var actions = [goal, shotOnTarget, shotOffTarget, assist, yellowCard, redCard, cancel]
        if let section = Section(rawValue: indexPath.section), section == .goalie {
            let save = UIAlertAction(title: "Save", style: .default) { _ in
                
            }
            actions.append(save)
        }
        
        let alertController = UIAlertController(title: "New Player Action", message: nil, preferredStyle: .actionSheet)
        for action in actions {
            alertController.addAction(action)
        }
        let rect = view.convert(cell.nameLabel.bounds, to: view)
        alertController.popoverPresentationController?.sourceView = cell.nameLabel
        alertController.popoverPresentationController?.sourceRect = rect
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
        guard let section = Section(rawValue: indexPath.section), let player = activePlayersPerSection[section]?[indexPath.row] else { return [] }
        let itemProvider = NSItemProvider(object: player)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = player
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ActivePlayerCell else { return nil }
        let previewParameters = UIDragPreviewParameters()
        previewParameters.backgroundColor = .clear
        let path = UIBezierPath(rect: cell.nameLabel.frame)
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
                if let sourceIndexPath = item.sourceIndexPath, let sourceSection = Section(rawValue: sourceIndexPath.section), let destinationPlayer = activePlayersPerSection[section]?[insertionIndexPath.row] {
                    activePlayersPerSection[section]?[insertionIndexPath.row] = movingPlayer
                    activePlayersPerSection[sourceSection]?[sourceIndexPath.row] = destinationPlayer
                }
            } else if playersForSection.count + 1 >= insertionIndexPath.row {
                activePlayersPerSection[section]?[insertionIndexPath.row] = movingPlayer
            } else {
                activePlayersPerSection[section]?.append(movingPlayer)
            }
            movingPlayer.isActive = true
            updateSnapshot()
        }
    }
    
}
