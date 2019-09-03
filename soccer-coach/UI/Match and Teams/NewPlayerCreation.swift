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
    @IBOutlet weak var deleteButton: UIButton!
    
    var player: SoccerPlayer?
    var team: Team?
    
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
        deleteButton.isHidden = player == nil
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
