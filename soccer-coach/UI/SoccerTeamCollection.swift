//
//  FirstViewController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class SoccerTeamCollection: UIViewController {
    
    enum Section: Int, CaseIterable {
        case frontLine, attackingMid, holdingMid, backLine, goalie
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, SoccerPlayer>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>! = nil
    var activePlayersPerSection: [Section: [SoccerPlayer]] = [:]
   
    var allActivePlayers: [SoccerPlayer] {
        return activePlayersPerSection.values.flatMap { $0 }
    }
    
    
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

}


private extension SoccerTeamCollection {
    
    func configureCollectionViewLayout() {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let collectionSection = Section(rawValue: sectionIndex) else { return nil }
            
            let columns = self.activePlayersPerSection[collectionSection]?.count ?? 0
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)
            
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
    
    func replace(with player: SoccerPlayer, at indexPath: IndexPath) {
        
    }
    
    func swapPlayers(_ playerOne: SoccerPlayer, at indexPathOne: IndexPath,  playerTwo: SoccerPlayer, as indexPathTwo: IndexPath) {
        
    }
    
    func remove(player: SoccerPlayer, from indexPath: IndexPath) {
        
    }
    
}


// MARK: - CollectionView delegate

extension SoccerTeamCollection: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .lightGray
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

