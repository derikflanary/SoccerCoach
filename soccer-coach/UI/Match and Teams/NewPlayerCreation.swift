//
//  NewPlayerCreation.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/2/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class NewPlayerCreation: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    
    var player: SoccerPlayer?
    var team: Team?
    var cellIdentifier = "cell"
    var playerCumulativeStats: PlayerCumulativeStats? {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    var number: String? {
        guard let text = numberTextField.text else { return nil }
        if let int = Int(text) {
            return String(int)
        } else {
            return nil
        }
    }
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = player?.name
        numberTextField.text = player?.number != "100" ? player?.number : nil
        numberTextField.delegate = self
        title = player == nil ? "New Player" : "Edit Player"
        navigationController?.toolbar.isHidden = player == nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        fetchData()
    }
    
    
    // MARK: - Actions
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let name = nameTextField.text else { return }
        
        if let player = player {
            player.name = name
            player.number = number
            SoccerPlayerController.shared.update(player)
        } else {
            guard let player = SoccerPlayerController.shared.createPlayer(with: name, number: numberTextField.text) else { return }
            team?.addToPlayers(player)
            App.sharedCore.fire(event: Created(item: player))
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let player = player else { return }
        SoccerPlayerController.shared.delete(player)
        self.team?.removeFromPlayers(player)
        dismiss(animated: true, completion: nil)
    }
    
    @IBSegueAction func showPositionDetail(_ coder: NSCoder) -> UIViewController? {
        guard let playerCumulativeStats = playerCumulativeStats else { return nil }
        return PlayerPositionCumulativeDetail(coder: coder, playerStats: playerCumulativeStats)
    }
    
    func fetchData() {
        guard let player = player else { return }
        let matches = MatchController.shared.fetchMatches(for: player)
        playerCumulativeStats = PlayerCumulativeStats(player: player, matches: matches)
    }
    
}


// MARK: - Text field delegate

extension NewPlayerCreation: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string != "" else { return true }
        if let _ = Int(string), let text = textField.text, text.count <= 1 {
            return true
        } else {
            return false
        }
    }
    
}


// MARK: - Tableview datasource

extension NewPlayerCreation: UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case minutesPerGame
        case positions
        case goals
        case assists
        case shotsPerGame
        case averageShotRating
        case foulsPerGame
                
        var title: String {
            switch self {
            case .minutesPerGame:
                return "Minutes Per Game"
            case .positions:
                return "Positions"
            case .goals:
                return "Goals"
            case .shotsPerGame:
                return "Shots Per Game"
            case .averageShotRating:
                return "Average Shot Rating"
            case .assists:
                return "Assists"
            case .foulsPerGame:
                return "Fouls"
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .minutesPerGame:
            return 1
        case .positions:
            return playerCumulativeStats?.positions.count ?? 0
        case .goals:
            return 1
        case .shotsPerGame:
            return 1
        case .averageShotRating:
            return 1
        case .assists:
            return 1
        case .foulsPerGame:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let section = Section(rawValue: indexPath.section) else { return cell }
        cell.accessoryType = .none
        guard let playerCumulativeStats = playerCumulativeStats else { return cell }
        switch section {
        case .minutesPerGame:
            cell.textLabel?.text = "\(playerCumulativeStats.minutesPerGame)"
        case .positions:
            let position = playerCumulativeStats.positions[indexPath.row]
            cell.textLabel?.text = "\(position.rawValue)"
            cell.accessoryType = .disclosureIndicator
        case .goals:
            cell.textLabel?.text = "\(playerCumulativeStats.totalGoals.count)"
        case .shotsPerGame:
            cell.textLabel?.text = String(format: "%.1f", playerCumulativeStats.shotsPerGame)
        case .averageShotRating:
            cell.textLabel?.text = "\(playerCumulativeStats.averageShotRating)"
        case .assists:
            cell.textLabel?.text = "\(playerCumulativeStats.assists.count)"
        case .foulsPerGame:
            cell.textLabel?.text = String(format: "%.1f", playerCumulativeStats.foulsPerGame)
        }
        return cell
    }
    
}


// MARK: - Tableview delgate

extension NewPlayerCreation: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .positions:
            performSegue(withIdentifier: .showPositionDetail, sender: nil)
        default:
            break
        }
    }
    
}


// MARK: - Segue handling

extension NewPlayerCreation: SegueHandling {
    
    enum SegueIdentifier: String {
        case showPositionDetail
    }
    
}
