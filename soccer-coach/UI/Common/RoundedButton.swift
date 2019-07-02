//
//  RoundedButton.swift
//  soccer-coach
//
//  Created by Derik Flanary on 7/1/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable open class RoundedButton: UIButton, Shakeable {
    
    enum RoundedEdgeType: CGFloat {
        case simple = 8
        case soft = 3
        case full = 2
        case none = 0
    }
    
    var loadingIndicator = UIActivityIndicatorView(style: .white)
    
    var roundedEdgeType: RoundedEdgeType = .simple {
        didSet {
            updateEdges()
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.10) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 1.02, y: 1.02) : .identity
                self.alpha = self.isHighlighted ? 0.9 : 1.0
            }
        }
    }
    
    @IBInspectable open var hasBordersOnSelection: Bool = false {
        didSet {
            updateBorders()
        }
    }
    
    @IBInspectable open var isLoading: Bool = false {
        didSet {
            updateLoadingState()
        }
    }
    
    @IBInspectable open var isShadowed: Bool = false {
        didSet {
            if isShadowed {
                addShadow()
            } else {
                removeShadow()
            }
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            if isEnabled {
                alpha = 1.0
            } else {
                alpha = 0.2
            }
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            updateBorders()
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        addLoadingIndicator()
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateEdges()
        addShadow()
        tintColor = .clear
    }
    
    private func updateEdges() {
        switch roundedEdgeType {
        case .simple, .soft, .full:
            layer.cornerRadius = frame.height / roundedEdgeType.rawValue
        case .none:
            layer.cornerRadius = 0
        }
        clipsToBounds = true
    }
    
    private func updateBorders() {
        guard hasBordersOnSelection else { return }
        if isSelected {
            layer.borderWidth = 3.0
            layer.borderColor = UIColor.secondarySystemBackground.cgColor
        } else {
            layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    override open func setTitle(_ title: String?, for state: UIControl.State) {
        let upTitle = title?.uppercased()
        super.setTitle(upTitle, for: state)
    }
    
    private func addShadow() {
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor.black.cgColor
        layer.masksToBounds = false
    }
    
    private func removeShadow() {
        layer.shadowOpacity = 0.0
        layer.shadowRadius = 0.0
        layer.masksToBounds = true
    }
    
    private func addLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func updateLoadingState() {
        if isLoading {
            loadingIndicator.startAnimating()
            isEnabled = false
            isHighlighted = false
            setTitleColor(.clear, for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            isEnabled = true
            setTitleColor(.white, for: .normal)
        }
    }
    
}


protocol Shakeable { }

// we can constrain the shake method to only UIViews!
extension Shakeable where Self: UIView {
    
    // default shake implementation
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        let fromPoint = CGPoint(x: center.x - 4, y: center.y)
        let toPoint = CGPoint(x: center.x + 4, y: center.y)
        animation.fromValue = NSValue(cgPoint: fromPoint)
        animation.toValue = NSValue(cgPoint: toPoint)
        layer.add(animation, forKey: "position")
    }
}
