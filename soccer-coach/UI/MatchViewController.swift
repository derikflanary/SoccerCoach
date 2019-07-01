//
//  MatchViewController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/30/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController {
    
    @IBOutlet weak var halfSegmentedControl: UISegmentedControl!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var homeTextField: UITextField!
    @IBOutlet weak var homeGoalLabel: UILabel!
    @IBOutlet weak var homeStepper: UIStepper!
    @IBOutlet weak var awayTextField: UITextField!
    @IBOutlet weak var awayGoalLabel: UILabel!
    @IBOutlet weak var awayStepper: UIStepper!
    
    var half: Half = .first
    var timer = Timer()
    var count: Int = 0
    var isRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startPauseButtonTapped() {
        isRunning.toggle()
        if isRunning {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerUpdated), userInfo: nil, repeats: true)
            startPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            timer.invalidate()
            startPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let selectedHalf = Half(rawValue: halfSegmentedControl.selectedSegmentIndex) else { return }
        half = selectedHalf
    }
    
    @objc func timerUpdated() {
        count += 1
        timeLabel.text = timeString(from: count)
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
    
}
