//
//  TeamList.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/2/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class TeamList: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    enum Section: Int, CaseIterable {
        case main
    }
    
    var dataSource: UITableViewDiffableDataSource<Section, Team>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Team>! = nil
    let cellIdentifier = "cell"
    var teams: [Team] = [Team(name: "Lone Peak", players: [SoccerPlayer(name: "Molly Molls"), SoccerPlayer(name: "Melissa Happybottom"), SoccerPlayer(name: "Ally Allison")]), Team(name: "American Fork", players: [])]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        configDataSource()
    }

    @IBAction func newButtonTapped(_ sender: Any) {
        
    }
    
}

private extension TeamList {
    
    func configDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, Team>(tableView: tableView, cellProvider: { tableView, indexPath, team -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = team.name
            return cell
        })
        updateTableUI()
    }
    
    func updateTableUI(animated: Bool = true) {
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Team>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(teams)
        self.dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
    
}

extension TeamList: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = teams[indexPath.row]
        navigationController?.popViewController(animated: true)
    }
    
}
