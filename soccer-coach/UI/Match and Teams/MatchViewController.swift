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
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var awayLabel: UILabel!
    @IBOutlet weak var homeGoalLabel: UILabel!
    @IBOutlet weak var homeStepper: UIStepper!
    @IBOutlet weak var awayGoalLabel: UILabel!
    @IBOutlet weak var awayStepper: UIStepper!
    @IBOutlet weak var createMatchButton: UIButton!
    @IBOutlet weak var endMatchButton: RoundedButton!
    @IBOutlet weak var mainStackView: UIStackView!
    
    
    // MARK: - Properties
    
    var match: Match? {
        didSet {
            guard match != oldValue else { return }
            updateUI(with: match)
            firstHalfTimeSubscriber = match?.$firstHalfTimeElapsed
                .map({
                    Int($0).timeString()
                })
                .receive(on: RunLoop.main)
                .assign(to: \.timeLabel.text, on: self)
            secondHalfTimeSubscriber = match?.$secondHalfTimeElapsed
                .map({
                    Int($0).timeString()
                })
                .receive(on: RunLoop.main)
                .assign(to: \.timeLabel.text, on: self)
            extraTimeSubscriber = match?.$firstHalfTimeElapsed
                .map({
                    Int($0).timeString()
                })
                .receive(on: RunLoop.main)
                .assign(to: \.timeLabel.text, on: self)
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

    var half: Half = .first
    var currentMatchSubscriber: AnyCancellable?
    var homeGoalSubscriber: AnyCancellable?
    var awayGoalSubscriber: AnyCancellable?
    var firstHalfTimeSubscriber: AnyCancellable?
    var secondHalfTimeSubscriber: AnyCancellable?
    var extraTimeSubscriber: AnyCancellable?

    var isRunning = false {
        didSet {
            guard let match = match else { return }
            if isRunning {
                if match.hasStarted {
                    match.resume()
                } else {
                    match.start()
                }
                match.hasStarted = true
                startPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                match.pause()
                startPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }
    }
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubscribers()
    }
    

    // MARK: - Actions
    
    @IBAction func startPauseButtonTapped() {
        isRunning.toggle()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let match = match else { return }
        switch half {
        case .first:
            if match.firstHalfTimeElapsed < Double(match.halfLength) * 60 {
                showHalfNotOverAlert()
                return
            }
        case .second:
            if match.firstHalfTimeElapsed < Double(match.halfLength) * 60 {
                showHalfNotOverAlert()
                return
            }
        case .extra:
            if match.firstHalfTimeElapsed < Double(match.halfLength) * 60 {
                showHalfNotOverAlert()
                return
            }
        }
        updateHalfSelected()
    }
    
    @IBAction func homeStepperChanged(_ sender: UIStepper) {
        let goalCount = Int64(sender.value)
        homeGoalLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func awayStepperChanged(_ sender: UIStepper) {
        let goalCount = Int64(sender.value)
        awayLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func endMatchTapped() {
        guard let match = match else { return }
        if match.isComplete {
            let alert = UIAlertController(title: "End Match?", message: "Are you sure you want to end and save this match?", preferredStyle: .alert)
            let save = UIAlertAction(title: "Save and End", style: .default) { _ in
                MatchController.shared.end(match)
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
        } else {
            let alert = UIAlertController(title: "End Match?", message: "The current match isn't yet complete. Are you sure you want to end and save this match?", preferredStyle: .alert)
            let save = UIAlertAction(title: "Save and End", style: .default) { _ in
                MatchController.shared.end(match)
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
        }
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
                self.createMatchButton.isHidden = false
            } else {
                self.mainStackView.alpha = 1.0
                self.mainStackView.isUserInteractionEnabled = true
                self.halfSegmentedControl.alpha = 1.0
                self.halfSegmentedControl.isUserInteractionEnabled = true
                self.endMatchButton.isHidden = false
                self.createMatchButton.isHidden = true
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
        guard let match = match, let selectedHalf = Half(rawValue: halfSegmentedControl.selectedSegmentIndex) else { return }
        half = selectedHalf
        isRunning = false
        match.half = Int64(half.rawValue)
        switch half {
        case .first:
            timeLabel.text = Int(match.firstHalfTimeElapsed).timeString()
        case .second:
            timeLabel.text = Int(match.secondHalfTimeElapsed).timeString()
        case .extra:
            timeLabel.text = Int(match.extraTimeTimeElaspsed).timeString()
        }
    }
    
}


// MARK: - Subscriberable

extension MatchViewController: Subscriberable {
    
    func configureSubscribers() {
        let state = App.sharedCore.state
        currentMatchSubscriber = state.matchState.$currentMatch
            .assign(to: \.match, on: self)
//        homeGoalSubscriber = state.matchState.$homeGoals
//            .assign(to: \.homeGoals, on: self)
//
//        awayGoalSubscriber = state.matchState.$awayGoals
//            .assign(to: \.awayGoals, on: self)
    }
    
}
