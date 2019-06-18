//
//  ListView+Extensions.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import UIKit

extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>() -> T where T: ReusableView {
        var dequeueCell: T? { return dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T }
        guard let cell = dequeueCell else {
            // make sure it is registered
            register(T.nib(), forCellReuseIdentifier: T.reuseIdentifier)
            return dequeueCell ?? T()
        }
        
        return cell
    }
    
}

extension UICollectionView {
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
    func dequeueReusableView<T: UICollectionReusableView>(for indexPath: IndexPath, of kind: String) -> T where T: ReusableView {
        guard let header = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else { fatalError("Could not dequeue header with identifier: \(T.reuseIdentifier)") }
        return header
    }
    
}
