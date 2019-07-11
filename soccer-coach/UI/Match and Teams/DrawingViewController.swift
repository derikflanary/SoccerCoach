//
//  ViewController.swift
//  PencilKitPlayground
//
//  Created by Benjamin Patch on 6/12/19.
//  Copyright © 2019 OCTanner. All rights reserved.
//

import UIKit
import PencilKit

class DrawingViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    @IBOutlet weak var imagesButton: UIBarButtonItem!
    
    var fullFieldImage = UIImage(named: "fullField")
    var goalBoxImage = UIImage(named: "goalBox")
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 30, y: -30, width: canvasView.frame.width - 60, height: canvasView.frame.height - 60))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    
    // MARK: - Life Cycle
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 100) // set the starting tool
        canvasView.maximumZoomScale = 3 // make it zoomable
        canvasView.bouncesZoom = true
        initializeToolPicker() // hook up the toolkit to the canvasView
        applyBackground(image: fullFieldImage)
    }

    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func imagesButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Select Background", message: nil, preferredStyle: .alert)
        let fullFieldAction = UIAlertAction(title: "Full Field", style: .default) { _ in
            self.imageView.image = self.fullFieldImage
            self.canvasView.drawing = PKDrawing()
        }
        let goalBoxAction = UIAlertAction(title: "Half Field", style: .default) { _ in
            self.imageView.image = self.goalBoxImage
            self.canvasView.drawing = PKDrawing()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(fullFieldAction)
        alertController.addAction(goalBoxAction)
        alertController.addAction(cancel)
        alertController.popoverPresentationController?.barButtonItem = imagesButton
        alertController.popoverPresentationController?.sourceView = view
        present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Methods
    
    /// Hook up the ToolPicker to the PKCanvasView and to `self` so we can listen to it's appearance and adjust layout for iPhone
    func initializeToolPicker() {
        guard let window = parent?.view.window, let toolPicker = PKToolPicker.shared(for: window) else { return }
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.addObserver(self)
        updateLayout(for: toolPicker)
        canvasView.becomeFirstResponder()
    }
    
    /// Adds a background image to the drawing that will zoom with the image.
    func applyBackground(image: UIImage? = nil, with drawing: PKDrawing? = nil) {
        if let image = image {
            // apply background image if one is provided
            view.layoutIfNeeded()
            imageView.image = image
            let imageSuperView = canvasView.subviews.first! // so the image zooms/scrolls with the drawing.
            imageSuperView.insertSubview(imageView, at: 0)
            canvasView.isOpaque = false // required for background color... .clear background color is not enough.
            canvasView.backgroundColor = .clear
        } else {
            canvasView.backgroundColor = .systemBackground
            canvasView.isOpaque = true
        }
    }
}


// MARK: - PKToolPickerObserver Conformance

/// This Code was grabbed from the example project. It makes it so the toolbar will be adjusted for iPhone.
extension DrawingViewController: PKToolPickerObserver {
    
    /// Delegate method: Note that the tool picker has changed which part of the canvas view
    /// it obscures, if any.
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
    
    /// Delegate method: Note that the tool picker has become visible or hidden.
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
    
    /// Helper method to adjust the canvas view size when the tool picker changes which part
    /// of the canvas view it obscures, if any.
    ///
    /// Note that the tool picker floats over the canvas in regular size classes, but docks to
    /// the canvas in compact size classes, occupying a part of the screen that the canvas
    /// could otherwise use.
    func updateLayout(for toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: view)
        
        // If the tool picker is floating over the canvas, it also contains
        // undo and redo buttons.
        if obscuredFrame.isNull {
            canvasView.contentInset = .zero
            navigationItem.leftBarButtonItems = []
        }
            
            // Otherwise, the bottom of the canvas should be inset to the top of the
            // tool picker, and the tool picker no longer displays its own undo and
            // redo buttons.
        else {
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.bounds.maxY - obscuredFrame.minY, right: 0)
            navigationItem.leftBarButtonItems = [undoButton, redoButton]
        }
        canvasView.scrollIndicatorInsets = canvasView.contentInset
    }

}
