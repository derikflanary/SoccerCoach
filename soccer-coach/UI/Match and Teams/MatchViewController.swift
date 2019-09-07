//
//  MatchViewController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/30/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit
import Combine

class MatchViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var halfSegmentedControl: UISegmentedControl!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var awayLabel: UILabel!
    @IBOutlet weak var homeGoalLabel: UILabel!
    @IBOutlet weak var homeStepper: UIStepper!
    @IBOutlet weak var awayGoalLabel: UILabel!
    @IBOutlet weak var awayStepper: UIStepper!
    @IBOutlet weak var createMatchButton: UIButton!
    @IBOutlet weak var beginHalfButton: RoundedButton!
    @IBOutlet weak var endMatchButton: RoundedButton!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var endHalfButton: RoundedButton!
    @IBOutlet weak var homeCornersLabel: UILabel!
    @IBOutlet weak var awayCornersLabel: UILabel!
    
    
    // MARK: - Properties
    
    var half: Half = .first
    var currentMatchSubscriber: AnyCancellable?
    var homeGoalSubscriber: AnyCancellable?
    var awayGoalSubscriber: AnyCancellable?
    var halfHasStartedSubscriber: AnyCancellable?
    var halfStarted = false
        
    var match: Match? {
        didSet {
            guard match != oldValue else { return }
            updateUI(with: match)
        }
    }
    var homeGoals: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.homeGoalLabel.text = String(self.homeGoals)
            }
        }
    }
    var awayGoals: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.awayGoalLabel.text = String(self.homeGoals)
            }
        }
    }
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubscribers()
    }
    

    // MARK: - Actions
    
    @IBAction func endHalfButtonTapped() {
        App.sharedCore.fire(event: HalfEnded())
        updateHalfSelected()
    }
    
    @IBAction func beginHalfButonTapped() {
        App.sharedCore.fire(event: HalfStarted())
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) { }
    
    @IBAction func homeStepperChanged(_ sender: UIStepper) {
        let goalCount = Int64(sender.value)
        homeGoalLabel.text = "\(goalCount)"
    }
    
    @IBAction func awayStepperChanged(_ sender: UIStepper) {
        let goalCount = Int64(sender.value)
        awayGoalLabel.text = "\(goalCount)"
    }
    
    @IBAction func homeCornersStepperChanged(_ sender: UIStepper) {
        homeCornersLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func awayCornersStepperChanged(_ sender: UIStepper) {
        awayCornersLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func endMatchTapped() {
        guard let match = match else { return }
        let alert = UIAlertController(title: "End Match?", message: "Are you sure you want to end and save this match?", preferredStyle: .alert)
        let save = UIAlertAction(title: "Save and End", style: .default) { _ in
            guard let homeCorners = Int64(self.homeCornersLabel.text ?? "0"), let awayCorners = Int64(self.awayCornersLabel.text ?? "0") else { return }
            MatchController.shared.end(match, homeCornerCount: homeCorners, awayCornerCount: awayCorners, homeScore: Int64(self.homeStepper.value), awayScore: Int64(self.awayStepper.value))
            App.sharedCore.fire(event: Selected<Match?>(item: nil))
        }
        let noSave = UIAlertAction(title: "End without Saving", style: .destructive) { _ in
            MatchController.shared.delete(match)
            App.sharedCore.fire(event: Selected<Match?>(item: nil))
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(save)
        alert.addAction(noSave)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
        MatchController.shared.save(match)
    }
    
    @IBAction func createMatchButtonTapped() { }

}


// MARK: - Private functions

private extension MatchViewController {
    
    func updateUI(with match: Match?) {
        DispatchQueue.main.async {
            if match == nil {
                self.mainStackView.alpha = 0.2
                self.mainStackView.isUserInteractionEnabled = false
                self.halfSegmentedControl.alpha = 0.2
                self.halfSegmentedControl.isUserInteractionEnabled = false
                self.endMatchButton.isHidden = true
                self.endHalfButton.isHidden = true
                self.beginHalfButton.isHidden = true
                self.createMatchButton.isHidden = false
            } else {
                self.mainStackView.alpha = 1.0
                self.mainStackView.isUserInteractionEnabled = true
                self.halfSegmentedControl.alpha = 1.0
                self.halfSegmentedControl.isUserInteractionEnabled = true
                self.halfSegmentedControl.selectedSegmentIndex = 0
                self.endMatchButton.isHidden = false
                self.createMatchButton.isHidden = true
                self.homeLabel.text = match?.homeTeam?.name
                self.awayLabel.text = match?.awayTeam?.name
                self.beginHalfButton.isHidden = false

            }
        }
    }
    
    func showHalfNotOverAlert() {
        let alert = UIAlertController(title: "Half not over", message: "The current half has not yet reached its limit. Are you sure you want to end the current half and continue?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Yes", style: .default) { _ in
            self.updateHalfSelected()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.halfSegmentedControl.selectedSegmentIndex = self.half.rawValue
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
        
    func updateHalfSelected() {
        guard let match = match, let selectedHalf = Half(rawValue: halfSegmentedControl.selectedSegmentIndex + 1), selectedHalf != .extra else { return }
        half = selectedHalf
        halfSegmentedControl.selectedSegmentIndex = half.rawValue
        match.half = Int64(half.rawValue)
    }
    
}


// MARK: - Subscriberable

extension MatchViewController: Subscriberable {
    
    func configureSubscribers() {
        let state = App.sharedCore.state
        currentMatchSubscriber = state.matchState.$currentMatch
            .assign(to: \.match, on: self)
        homeGoalSubscriber = state.matchState.$homeGoals
            .assign(to: \.homeGoals, on: self)
        awayGoalSubscriber = state.matchState.$awayGoals
            .assign(to: \.awayGoals, on: self)
        halfHasStartedSubscriber = state.matchState.$halfStarted
        .sink(receiveValue: { halfStarted in
            DispatchQueue.main.async {
                if let match = self.match, match.currentHalf == .extra {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.beginHalfButton.alpha = 0.0
                        self.endHalfButton.alpha = 0.0
                    }) { _ in
                        self.beginHalfButton.isHidden = true
                        self.endHalfButton.isHidden = true
                    }
                } else if self.match == nil {
                    self.beginHalfButton.isHidden = true
                    self.endHalfButton.isHidden = true
                    self.endHalfButton.isHidden = true
                    self.beginHalfButton.isHidden = true
                } else {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.endHalfButton.alpha = !halfStarted ? 0.0 : 1.0
                        self.beginHalfButton.alpha = halfStarted ? 0.0 : 1.0
                    }) { _ in
                        self.beginHalfButton.isHidden = halfStarted
                        self.endHalfButton.isHidden = !halfStarted
                    }
                }
            }
        })
    }
    
}
