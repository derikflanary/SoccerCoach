//
//  SecondViewController.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit
import VisionKit

class TeamList: UIViewController {
    
    enum Section: Int, CaseIterable {
        case home
        case away
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamSegmentedControl: UISegmentedControl!
    
    var dataSource: UITableViewDiffableDataSource<Section, SoccerPlayer>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>! = nil
    let cellIdentifier = "cell"
    var currentSection = Section.home
    var homeTeam = Team(name: "Lone Peak", players: [SoccerPlayer(name: "Molly Molls"), SoccerPlayer(name: "Melissa Happybottom"), SoccerPlayer(name: "Ally Allison")])
    var awayTeam = Team(name: "American Fork", players: [])
    
    var currentTeam: Team {
        switch currentSection {
        case .home:
            return homeTeam
        case .away:
            return awayTeam
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dragDelegate = self
        configDataSource()
    }


    @IBAction func scanTapped(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let documentViewController = VNDocumentCameraViewController()
            documentViewController.delegate = self
            present(documentViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func teamSegmentedControlChanged(_ sender: UISegmentedControl) {
        currentSection = Section(rawValue: sender.selectedSegmentIndex) ?? .home
        updateTableUI()
    }
    
}


private extension TeamList {
    
    func configDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, SoccerPlayer>(tableView: tableView, cellProvider: { tableView, indexPath, player -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = player.name
            cell.imageView?.image = player.isActive ? UIImage(systemName: "circle.fill") : nil
            return cell
        })
        updateTableUI()
    }
    
    func updateTableUI(animated: Bool = true) {
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, SoccerPlayer>()
        currentSnapshot.appendSections([currentSection])
        currentSnapshot.appendItems(currentTeam.players)
        self.dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
}


// MARK: - Camera Document Delegate

@available(iOS 13.0, *)
extension TeamList: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let recognitionEngine = TextRecognitionEngine()
        controller.dismiss(animated: true)
        recognitionEngine.process(scan) { resultingStrings in
            DispatchQueue.main.async {
                for string in resultingStrings {
                    let player = SoccerPlayer(name: string)
                    switch self.currentSection {
                    case .home:
                        self.homeTeam.players.append(player)
                    case .away:
                        self.awayTeam.players.append(player)
                    }
                }
                self.updateTableUI()
            }
        }
    }

}

extension TeamList: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let player = currentTeam.players[indexPath.row]
        let itemProvider = NSItemProvider(object: player)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = player
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        tableView.reloadData()
    }
    
}
