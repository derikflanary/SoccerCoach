//
//  CreateNewTeam.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/2/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit
import VisionKit
import CoreData

class NewTeamCreation: UIViewController {
    
    enum Section: CaseIterable {
        case main
    }

    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var addPlayerButton: UIBarButtonItem!
    @IBOutlet weak var scanButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: UITableViewDiffableDataSource<Section, SoccerPlayer>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>! = nil
    let cellIdentifier = "cell"
    var players = [SoccerPlayer]()
    var tapGesture = UITapGestureRecognizer()
    var selectedPlayer: SoccerPlayer? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        configDataSource()
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        performSegue(withIdentifier: .unwindToTeamList, sender: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let name = teamNameTextField.text else { return }
        _ = TeamController.shared.createTeam(with: name, players: players)
        performSegue(withIdentifier: .unwindToTeamList, sender: nil)
    }
    
    @IBAction func addPlayerTapped(_ sender: Any) {
        
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let documentViewController = VNDocumentCameraViewController()
            documentViewController.delegate = self
            present(documentViewController, animated: true, completion: nil)
        }
    }
    
    @objc func tapped() {
        teamNameTextField.resignFirstResponder()
    }
    
}


private extension NewTeamCreation {
    
    // MARK: - Datasource
    
    func configDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, SoccerPlayer>(tableView: tableView, cellProvider: { tableView, indexPath, player -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = player.name
            return cell
        })
        updateTableUI()
    }
    
    
    func updateTableUI(animated: Bool = true) {
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, SoccerPlayer>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(players)
        self.dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
    
}


extension NewTeamCreation: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlayer = players[indexPath.row]
        performSegue(withIdentifier: .showPlayerDetails, sender: nil)
    }
    
}


// MARK: - Presentation controller delegate

extension NewTeamCreation: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("attempt")
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        guard let parent = self.presentingViewController as? TeamList else { return }
        parent.viewWillAppear(true)
    }
    
}

// MARK: - Camera Document Delegate

@available(iOS 13.0, *)
extension NewTeamCreation: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let recognitionEngine = TextRecognitionEngine()
        controller.dismiss(animated: true)
        recognitionEngine.process(scan) { resultingStrings in
            DispatchQueue.main.async {
                for name in resultingStrings {
                    if let newPlayer = SoccerPlayerController.shared.createPlayer(with: name) {
                        self.players.append(newPlayer)                        
                    }
                }
                self.updateTableUI()
            }
        }
    }
    
}


// MARK: - Segue handling

extension NewTeamCreation: SegueHandling {
    
    enum SegueIdentifier: String {
        case showPlayerDetails
        case unwindToTeamList
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailNav = segue.destination as? UINavigationController else { return }
        guard let detail = detailNav.topViewController as? NewPlayerCreation else { return }
        detail.player = selectedPlayer
    }
    
}
