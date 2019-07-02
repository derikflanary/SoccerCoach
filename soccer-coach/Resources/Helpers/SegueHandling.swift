//
//  SegueHandling.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/2/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation
import UIKit

public protocol SegueHandling {
    associatedtype SegueIdentifier: RawRepresentable
}

public extension SegueHandling where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func performSegue(withIdentifier segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
    
    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier)
            else { fatalError("Invalid segue identifier \(String(describing: segue.identifier)).") }
        return segueIdentifier
    }
    
}
