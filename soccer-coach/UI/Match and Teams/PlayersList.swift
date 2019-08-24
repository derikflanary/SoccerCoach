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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableUI()
    }
    
}


// MARK: - Datasource

private extension PlayersList {
    
    func configDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, SoccerPlayer>(tableView: tableView, cellProvider: { tableView, indexPath, player -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = player.name
            cell.detailTextLabel?.text = player.number
            return cell
        })
        updateTableUI()
    }
    
    
    func updateTableUI(animated: Bool = true) {
        guard let team = team else { return }
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, SoccerPlayer>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(Array(team.players.sorted { $0.name < $1.name }))
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            guard let player = self.dataSource.itemIdentifier(for: indexPath) else { return }
            SoccerPlayerController.shared.delete(player)
            self.team?.removeFromPlayers(player)
            self.updateTableUI()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}


// MARK: - Segue handling

extension PlayersList: SegueHandling {
    
    enum SegueIdentifier: String {
        case showPlayerDetails
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailNav = segue.destination as? UINavigationController else { return }
        guard let detail = detailNav.topViewController as? NewPlayerCreation else { return }
        detail.player = selectedPlayer
        detail.team = team
    }
    
}
