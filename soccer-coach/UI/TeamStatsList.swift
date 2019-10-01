//
//  TeamList.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/2/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class TeamStatsList: UIViewController {

    // MARK: - Enums
    
    enum Section: Int, CaseIterable {
        case main
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    
    
    // MARK: - Properties
    
    var dataSource: UITableViewDiffableDataSource<Section, Team>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Team>! = nil
    let cellIdentifier = "cell"
    var teams = [Team]()
    var selectedTeam: Team?
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        configDataSource()
        fetchData()
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != SegueIdentifier.showPlayersList.rawValue {
            let detailNav = segue.destination as! UINavigationController
            let detail = detailNav.topViewController as! NewTeamCreation
            navigationController?.presentationController?.delegate = detail
        }
    }
    
    @IBSegueAction func showPlayersList(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UIViewController? {
        return PlayersList(coder: coder, team: selectedTeam)
    }
    
}


// MARK: - Private functions

private extension TeamStatsList {
    
    func fetchData() {
        teams = TeamController.shared.fetchAllTeams()
        updateTableUI()
    }
    
    func configDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, Team>(tableView: tableView, cellProvider: { tableView, indexPath, team -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = team.name
            return cell
        })
    }
    
    func updateTableUI(animated: Bool = true) {
        tableView.backgroundView = teams.isEmpty ? emptyView : nil
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Team>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(teams)
        dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
    
}


// MARK: - Tableview delegate

extension TeamStatsList: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedTeam = teams[indexPath.row]
        performSegue(withIdentifier: .showPlayersList, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            guard let team = self.dataSource.itemIdentifier(for: indexPath) else { return }
            TeamController.shared.delete(team)
            self.fetchData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}


// MARK: - Segue handling

extension TeamStatsList: SegueHandling {
    
    enum SegueIdentifier: String {
        case showPlayersList
    }
    
}
