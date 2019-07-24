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
    
    // MARK: - Enums
    
    enum Section: Int, CaseIterable {
        case home
        case away
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamSegmentedControl: UISegmentedControl!
    @IBOutlet var emptyStateView: UIView!
    
    
    // MARK: - Properties
    
    var dataSource: UITableViewDiffableDataSource<Section, SoccerPlayer>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>! = nil
    let cellIdentifier = "cell"
    var currentSection = Section.home
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dragDelegate = self
        configDataSource()
        configureSubscribers()
    }
    
    
    // MARK: - Actions
    
    @IBAction func teamSegmentedControlChanged(_ sender: UISegmentedControl) {
        currentSection = Section(rawValue: sender.selectedSegmentIndex) ?? .home
        updateTableUI()
    }
    
}


// MARK: - Private functions

private extension CurrentTeams {
    
    func configDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, SoccerPlayer>(tableView: tableView, cellProvider: { tableView, indexPath, player -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = player.name
            cell.imageView?.image = player.isActive ? UIImage(systemName: "circle.fill") : nil
            return cell
        })
        updateTableUI()
    }
    
    func updateTableUI(animated: Bool = true) {
        DispatchQueue.main.async {
            self.currentSnapshot = NSDiffableDataSourceSnapshot<Section, SoccerPlayer>()
            self.currentSnapshot.appendSections([self.currentSection])
            self.tableView.backgroundView = self.currentMatch == nil ? self.emptyStateView : nil
            guard let currentTeam = self.currentTeam else { return }
            self.currentSnapshot.appendItems(Array(currentTeam.players))
            self.dataSource.apply(self.currentSnapshot, animatingDifferences: animated)
        }
    }
    
}


// MARK: - Tableview delegate

extension CurrentTeams: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedPlayer = dataSource.itemIdentifier(for: indexPath)
        performSegue(withIdentifier: .presentPlayerDetails, sender: nil)
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
