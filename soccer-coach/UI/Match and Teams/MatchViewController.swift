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
        }
    }
    var half: Half = .first
    var timer = Timer()
    var firstHalfCount: Int = 0
    var secondHalfCount: Int = 0
    var savedDate: Date?
    var currentMatchSubscriber: AnyCancellable?

    var isRunning = false {
        didSet {
            if isRunning {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerUpdated), userInfo: nil, repeats: true)
                startPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                timer.invalidate()
                startPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }
    }
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appPaused), name: UIApplication.didEnterBackgroundNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumedApp), name: UIApplication.didBecomeActiveNotification , object: nil)
        configureSubscribers()
    }
    
      
    // MARK: - Actions

    @objc func appPaused() {
        guard timer.isValid else { return }
        savedDate = Date()
        isRunning.toggle()
    }
    
    @objc func resumedApp() {
        guard let savedDate = savedDate else { return }
        let difference = abs(Int(savedDate.timeIntervalSinceNow))
        switch half {
        case .first:
            firstHalfCount += difference
            timeLabel.text = timeString(from: firstHalfCount)
        case .second:
            secondHalfCount += difference
            timeLabel.text = timeString(from: secondHalfCount)
        case .extra:
            break
            // TODO: Add extra time support
        }
        isRunning.toggle()
    }
    
    @IBAction func startPauseButtonTapped() {
        isRunning.toggle()
        
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let selectedHalf = Half(rawValue: halfSegmentedControl.selectedSegmentIndex) else { return }
        half = selectedHalf
        isRunning = false
        switch half {
        case .first:
            timeLabel.text = timeString(from: firstHalfCount)
        case .second:
            timeLabel.text = timeString(from: secondHalfCount)
        case .extra:
            break
            // TODO: Add extra time support
        }
        
    }
    
    @objc func timerUpdated() {
        switch half {
        case .first:
            firstHalfCount += 1
            timeLabel.text = timeString(from: firstHalfCount)
        case .second:
            secondHalfCount += 1
            timeLabel.text = timeString(from: secondHalfCount)
        case .extra:
            break
            // TODO: Add extra time support
        }
        if let halfLength = match?.halfLength, firstHalfCount.minutes >= halfLength + 10 {
            timer.invalidate()
        }
    }
    
    func timeString(from seconds: Int) -> String {
        let mins = seconds.minutes
        let remainingSeconds = seconds - (mins * 60)
        let minuteString = mins < 10 ? "0\(mins)" : "\(mins)"
        let secondsString = remainingSeconds < 10 ? "0\(remainingSeconds)" : "\(remainingSeconds)"
        return "\(minuteString):\(secondsString)"
    }
    
    @IBAction func homeStepperChanged(_ sender: UIStepper) {
        homeGoalLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func awayStepperChanged(_ sender: UIStepper) {
        awayGoalLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func createMatchButtonTapped() {
        
    }
    
    @IBAction func endMatchTapped() {
        
    }
    
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
    
}


// MARK: - Subscriberable

extension MatchViewController: Subscriberable {
    
    func configureSubscribers() {
        let state = App.sharedCore.state
        currentMatchSubscriber = state.matchState.$currentMatch
            .assign(to: \.match, on: self)
    }
    
}
