//
//  ShotDetail.swift
//  soccer-coach
//
//  Created by Derik Flanary on 8/28/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class ShotDetail: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let shot: Shot
    let match: Match
    let cellIdentifier = "cell"
    
    // MARK: - Initializers
    
    init?(coder: NSCoder, shot: Shot, match: Match) {
        self.shot = shot
        self.match = match
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        navigationController?.isToolbarHidden = true
    }

}

// MARK: - TableView datasource

extension ShotDetail: UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case minute
        case rating
        case description
        case assist
        case delete
                
        var title: String? {
            switch self {
            case .minute:
                return "Minute"
            case .rating:
                return "Rating"
            case .description:
                return "Description"
            case .assist:
                return "Assist"
            case .delete:
                return nil
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let section = Section(rawValue: indexPath.section) else { return cell }
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.textColor = .label
        switch section {
        case .minute:
            cell.textLabel?.text = "\(shot.minuteString(halfLength: Int(match.halfLength)))"
        case .rating:
            cell.textLabel?.text = "\(shot.rating)"
        case .description:
            cell.textLabel?.text = shot.shotDescription
        case .assist:
            cell.textLabel?.text = shot.assist?.playingTime?.player?.name
        case .delete:
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.text = "Delete"
        }
        return cell
    }
    
}


// MARK: - Tableview delegate

extension ShotDetail: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = Section(rawValue: indexPath.section), section == .delete else { return }
        let alert = UIAlertController(title: "Delete Shot?", message: "Are you sure you want to delete this shot?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            PlayingTimeController.shared.deleteShot(self.shot)
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
