//
//  SecondViewController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class CurrentTeams: UIViewController {
    
    // MARK: - Enums
    
    enum Section: Int, CaseIterable {
        case home
        case away
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamSegmentedControl: UISegmentedControl!
    
    
    // MARK: - Properties
    
    var dataSource: UITableViewDiffableDataSource<Section, SoccerPlayer>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>! = nil
    let cellIdentifier = "cell"
    var currentSection = Section.home
    var homeTeam = Team(name: "Lone Peak", players: [SoccerPlayer(name: "Molly Molls"), SoccerPlayer(name: "Melissa Happybottom"), SoccerPlayer(name: "Ally Allison")])
    var awayTeam = Team(name: "American Fork", players: [])
    
    var currentTeam: Team {
        switch currentSection {
        case .home:
            return homeTeam
        case .away:
            return awayTeam
        }
    }
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dragDelegate = self
        configDataSource()
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
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, SoccerPlayer>()
        currentSnapshot.appendSections([currentSection])
        currentSnapshot.appendItems(currentTeam.players)
        self.dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
    
}


// MARK: - Tableview delegate

extension CurrentTeams: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let player = currentTeam.players[indexPath.row]
        // TODO: - show player details
    }
    
}


// MARK: - Drag delegate

extension CurrentTeams: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let player = currentTeam.players[indexPath.row]
        let itemProvider = NSItemProvider(object: player)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = player
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        tableView.reloadData()
    }
    
}
