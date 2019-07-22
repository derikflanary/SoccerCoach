//
//  PlayersList.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/22/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class PlayersList: UIViewController {
    
    // MARK: - Enums
    
    enum Section: CaseIterable {
        case main
    }

    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties
    
    var dataSource: UITableViewDiffableDataSource<Section, SoccerPlayer>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>! = nil
    let cellIdentifier = "cell"
    var team: Team?
    var selectedPlayer: SoccerPlayer?
    
    
    // MARK: - Initializers
    
    init?(coder: NSCoder, team: Team?) {
        self.team = team
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        configDataSource()
        title = team?.name
    }

    @IBSegueAction func showPlayerDetails(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UIViewController? {
        return PlayerDetails(coder: coder, player: selectedPlayer)
    }
    
}


// MARK: - Datasource

private extension PlayersList {
    
    func configDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, SoccerPlayer>(tableView: tableView, cellProvider: { tableView, indexPath, player -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = player.name
            cell.accessoryType = .disclosureIndicator
            return cell
        })
        updateTableUI()
    }
    
    
    func updateTableUI(animated: Bool = true) {
        guard let team = team else { return }
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, SoccerPlayer>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(Array(team.players))
        self.dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
    
}


// MARK: - Tableview delegate

extension PlayersList: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedPlayer = dataSource.itemIdentifier(for: indexPath)
        performSegue(withIdentifier: .showPlayerDetails, sender: nil)
    }
    
}


// MARK: - Segue handling

extension PlayersList: SegueHandling {
    
    enum SegueIdentifier: String {
        case showPlayerDetails
    }
    
}
