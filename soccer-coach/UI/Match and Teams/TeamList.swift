//
//  TeamList.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/2/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class TeamList: UIViewController {

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    @IBAction func unwindToTeamList(_ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    func fetchData() {
        teams = TeamController.shared.fetchAllTeams()
        updateTableUI()
    }

    @IBSegueAction func showPlayersList(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UIViewController? {
        return PlayersList(coder: coder, team: selectedTeam)
    }
    
    // MARK: - Actions
    
    @IBAction func newButtonTapped(_ sender: Any) {
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != SegueIdentifier.showPlayersList.rawValue {
            let detailNav = segue.destination as! UINavigationController
            let detail = detailNav.topViewController as! NewTeamCreation
            navigationController?.presentationController?.delegate = detail
        }
    }
    
}


// MARK: - Private functions

private extension TeamList {
    
    func configDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, Team>(tableView: tableView, cellProvider: { tableView, indexPath, team -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = team.name
            cell.accessoryType = .detailButton
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

extension TeamList: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = teams[indexPath.row]
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        selectedTeam = teams[indexPath.row]
        performSegue(withIdentifier: .showPlayersList, sender: nil)
    }
    
}


// MARK: - Segue handling

extension TeamList: SegueHandling {
    
    enum SegueIdentifier: String {
        case showPlayersList
    }
    
}
