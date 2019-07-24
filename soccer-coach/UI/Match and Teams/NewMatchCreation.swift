//
//  NewMatchCreation.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/2/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit
import Combine

class NewMatchCreation: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var homeTeam: Team? {
        didSet {
            tableView.reloadData()
        }
    }
    var awayTeam: Team? {
       didSet {
           tableView.reloadData()
       }
    }
    var halfLength: Int = 40
    var date = Date()
    var selectedSection: Section?
    var selectedTeamType = TeamType.home
    var awayTeamSubscriber: AnyCancellable?
    var homeTeamSubscriber: AnyCancellable?
    
    private let cellIdentifier = "matchCreationCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSubscribers()
    }
    
    
    // MARK: - Actions
    
    @IBAction func cancelTapped(_ sender: Any) {
        App.sharedCore.fire(event: Selected<Team?>(item: nil))
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let homeTeam = homeTeam, let awayTeam = awayTeam else { return }
        let match = MatchController.shared.createMatch(with: homeTeam, awayTeam: awayTeam, halfLength: halfLength, date: date)
        App.sharedCore.fire(event: Selected(item: match))
    }
    
    @IBAction func datePickerValueChanged() {
        switch datePicker.datePickerMode {
        case .countDownTimer:
            halfLength = Int(datePicker.countDownDuration).minutes
        case .date:
            date = datePicker.date
        default:
            break
        }
        tableView.reloadData()
    }
    
    @IBSegueAction func showTeamList(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> UIViewController? {
        return TeamList(coder: coder, teamType: selectedTeamType)
    }
    
}


// MARK: - Subscriberable

extension NewMatchCreation: Subscriberable {
    
    func configureSubscribers() {
        let state = App.sharedCore.state
        homeTeamSubscriber = state.matchState.$newMatchHomeTeam
            .receive(on: RunLoop.main)
            .assign(to: \.homeTeam, on: self)
        
        awayTeamSubscriber = state.matchState.$newMatchAwayTeam
            .assign(to: \.awayTeam, on: self)
    }
    
}


// MARK: - Tableview datasource

extension NewMatchCreation: UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case homeTeam
        case awayTeam
        case halfLength
        case date
        
        var title: String {
            switch self {
            case .homeTeam:
                return "Home Team"
            case .awayTeam:
                return "Away Team"
            case .halfLength:
                return "Half Length"
            case .date:
                return "Game Date"
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let section = Section(rawValue: indexPath.section) else { return cell }
        switch section {
        case .homeTeam:
            cell.textLabel?.text = homeTeam?.name ?? "Select a team"
        case .awayTeam:
            cell.textLabel?.text = awayTeam?.name ?? "Select a team"
        case .halfLength:
            cell.textLabel?.text = "\(halfLength) minutes"
        case .date:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            cell.textLabel?.text = dateFormatter.string(from: date).capitalized
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
}


// MARK: - Tableview delegate

extension NewMatchCreation: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .homeTeam:
            selectedTeamType = .home
            hideDatePicker()
            performSegue(withIdentifier: .showTeamList, sender: nil)
        case .awayTeam:
            selectedTeamType = .away
            hideDatePicker()
            performSegue(withIdentifier: .showTeamList, sender: nil)
        case .halfLength:
            if selectedSection == section {
                hideDatePicker()
                selectedSection = nil
            } else {
                datePicker.datePickerMode = .countDownTimer
                datePicker.minuteInterval = 5
                datePicker.countDownDuration = TimeInterval(halfLength * 60)
                showDatePicker()
                selectedSection = section
            }
        case .date:
            if selectedSection == section {
                hideDatePicker()
                selectedSection = nil
            } else {
                datePicker.datePickerMode = .date
                datePicker.date = date
                showDatePicker()
                selectedSection = section
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}


// MARK: - Private functions

private extension NewMatchCreation {
    
    func showDatePicker() {
        guard datePicker.alpha == 0.0 else { return }
        datePicker.transform = CGAffineTransform(scaleX: 0.10, y: 0.10)
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            self.datePicker.transform = .identity
            self.datePicker.alpha = 1.0
        })
    }
    
    func hideDatePicker() {
        datePicker.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            self.datePicker.transform = .identity
            self.datePicker.alpha = 0.0
        })
    }
    
}


extension NewMatchCreation: SegueHandling {
    
    enum SegueIdentifier: String {
        case showTeamList
    }
    
}
