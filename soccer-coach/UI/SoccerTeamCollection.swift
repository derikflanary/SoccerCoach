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
    
}

extension SoccerTeamCollection: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .lightGray
    }
}

extension SoccerTeamCollection: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            guard let player = item.dragItem.localObject as? SoccerPlayer else { continue }
            let insertionIndexPath = destinationIndexPath
            guard let section = Section(rawValue: insertionIndexPath.section) else { continue }
            guard let playersForSection = activePlayersPerSection[section], !activePlayersContains(player) else { continue }
            if playersForSection.count + 1 <= insertionIndexPath.row {
                activePlayersPerSection[section]?[insertionIndexPath.row] = player
            } else {
                activePlayersPerSection[section]?.append(player)
            }
            player.isActive = true
            updateSnapshot()
        }
    }
    
    
}

