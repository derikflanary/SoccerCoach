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
    
    enum Section: CaseIterable {
        case main
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: UITableViewDiffableDataSource<Section, SoccerPlayer>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, SoccerPlayer>! = nil
    var players = [SoccerPlayer]()
    let cellIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        configDataSource()
    }


    @IBAction func scanTapped(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let documentViewController = VNDocumentCameraViewController()
            documentViewController.delegate = self
            present(documentViewController, animated: true, completion: nil)
        }
    }
    
}


private extension TeamList {
    
    func configDataSource() {
        self.dataSource = UITableViewDiffableDataSource<Section, SoccerPlayer>(tableView: tableView, cellProvider: { tableView, indexPath, player -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = player.name
            return cell
        })
    }
    
    func updateTableUI(animated: Bool = true) {
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, SoccerPlayer>()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(players)
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
                    self.players.append(player)
                }
                self.updateTableUI()
            }
        }
    }

}
