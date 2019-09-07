//
//  MatchHistoryList.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/2/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class MatchHistoryList: UIViewController {

    // MARK: - Enums
    
    enum Section: Int, CaseIterable {
        case main
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    
    
    // MARK: - Properties
    
    var dataSource: UITableViewDiffableDataSource<Section, Match>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Match>! = nil
    let cellIdentifier = "cell"
    var matches = [Match]() {
        didSet {
            updateTableUI()
        }
    }
    var selectedMatch: Match?
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDataSource()
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    func fetchData() {
        matches = MatchController.shared.fetchAllMatches()
    }
    
    @IBAction func unwindToHistory(_ segue: UIStoryboardSegue) {
        fetchData()
    }
    
}


// MARK: - Private functions

private extension MatchHistoryList {
    
    func configDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, Match>(tableView: tableView, cellProvider: { tableView, indexPath, match -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = match.summary
            cell.detailTextLabel?.text = match.date.monthDayYearString
            return cell
        })
    }
    
    func updateTableUI(animated: Bool = true) {
        tableView.backgroundView = matches.isEmpty ? emptyView : nil
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Match>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(matches)
        self.dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
    
}


// MARK: - Tableview delegate

extension MatchHistoryList: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedMatch = matches[indexPath.row]
        let teams = TeamController.shared.fetchAllTeams()
        performSegue(withIdentifier: .presentMatchDetails, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            guard let match = self.dataSource.itemIdentifier(for: indexPath) else { return }
            MatchController.shared.delete(match)
            self.fetchData()
            self.updateTableUI()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}


// MARK: - Segue handling

extension MatchHistoryList: SegueHandling {
    
    enum SegueIdentifier: String {
        case presentMatchDetails
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailNav = segue.destination as? UINavigationController else { return }
        guard let detail = detailNav.topViewController as? MatchDetail else { return }
        detail.match = selectedMatch
    }
    
}
