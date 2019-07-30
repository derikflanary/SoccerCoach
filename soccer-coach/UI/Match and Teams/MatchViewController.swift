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
    var half: Half = .first
    var currentMatchSubscriber: AnyCancellable?
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
            if match.firstHalfTimeElapsed < Double(match.halfLength) {
                showHalfNotOverAlert()
                return
            }
        case .second:
            if match.firstHalfTimeElapsed < Double(match.halfLength) {
                showHalfNotOverAlert()
                return
            }
        case .extra:
            if match.firstHalfTimeElapsed < Double(match.halfLength) {
                showHalfNotOverAlert()
                return
            }
        }
    }
    
    @IBAction func homeStepperChanged(_ sender: UIStepper) {
        homeGoalLabel.text = "\(Int(sender.value))"
        match?.score?.home = Int64(sender.value)
    }
    
    @IBAction func awayStepperChanged(_ sender: UIStepper) {
        awayGoalLabel.text = "\(Int(sender.value))"
        match?.score?.away = Int64(sender.value)
    }
    
    @IBAction func endMatchTapped() {
        guard let match = match else { return }
        if match.isComplete {
            MatchController.shared.save(match)
        } else {
            let alert = UIAlertController(title: "End Match?", message: "The current match isn't yet complete. Are you sure you want to end and save this match?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Yes", style: .default) { _ in
                MatchController.shared.save(match)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func createMatchButtonTapped() {
            
    }

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
        let alert = UIAlertController(title: "Half not over", message: "The current half has not yet reached its limit. Are you sure you want to continue?", preferredStyle: .alert)
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
        match.half = Int64(half.rawValue)
        isRunning = false
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
        
    }
    
}
