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
    
    var player: SoccerPlayer?
    
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
            _ = SoccerPlayerController.shared.createPlayer(with: name, number: numberTextField.text)
        }
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
