//
//  HomeViewController.swift
//  VideoBalance
//
//  Created by Cristi Habliuc on 11/04/2019.
//  Copyright © 2019 Cristi Habliuc. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var actionButton: UIButton!
    
    @IBOutlet var angleSliderContainer: UIView!
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var minAngleLabel: UILabel!
    @IBOutlet var maxAngleLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    fileprivate var viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureModelBindings()
        
        updateUI(animated: false)
    }
    
    fileprivate func configureUI() {
        minAngleLabel.text = "\(Int(viewModel.minimumTrackedAngle))°"
        maxAngleLabel.text = "\(Int(viewModel.maximumTrackedAngle))°"
        angleSlider.minimumValue = Float(viewModel.minimumTrackedAngle)
        angleSlider.maximumValue = Float(viewModel.maximumTrackedAngle)
    }
    
    fileprivate func configureModelBindings() {
        viewModel.bindToStateChange { [weak self] _ in
            self?.updateUI(animated: false)
        }
        
        viewModel.bindToTiltAngleChange { [weak self] angle in
            self?.angleSlider.value = Float(angle)
        }
    }
    
    fileprivate func updateUI(animated: Bool = false) {
        if animated {
            let duration = AppConfiguration.defaultAnimDuration
            UIView.animate(withDuration: duration) {
                self.updateUI(animated: false)
            }
        } else {
            // here
            switch viewModel.state {
            case .error(let message):
                showError(message: message)
            case .initial:
                actionButton.isEnabled = true
                actionButton.setTitle("Download", for: .normal)
                angleSliderContainer.alpha = 0
                updateStatusInfo("Tap the Download button to begin")
            case .downloading:
                updateStatusInfo("Downloading...")
                actionButton.isEnabled = false
            case .downloaded:
                updateStatusInfo("Unzipping...")
                actionButton.isEnabled = false
            case .unzipped:
                updateStatusInfo("Unzipped.")
                actionButton.isEnabled = false
            case .waiting:
                updateStatusInfo("Waiting to stabilize...")
                actionButton.setTitle("Start", for: .normal)
                actionButton.isEnabled = false
                angleSliderContainer.alpha = 1
            case .ready:
                updateStatusInfo("Ready!")
                actionButton.isEnabled = true
                angleSliderContainer.alpha = 1
            case .finished:
                updateStatusInfo("Finished.")
                angleSliderContainer.alpha = 0
                actionButton.isEnabled = false
            }
        }
    }
    
    /// Updates the label at the bottom of the screen
    fileprivate func updateStatusInfo(_ message: String) {
        statusLabel.text = message
    }
    
    /// Presents the error to the user. For now it's a simple alert
    fileprivate func showError(message: String) {
        Logger.error(message)
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true) { [weak self] in
            self?.reset()
        }
    }
    
    /// Resets the scenario
    fileprivate func reset() {
        viewModel.reset()
    }

    @IBAction func handleActionButtonTap(_ sender: Any) {
        if case .initial = viewModel.state {
            viewModel.begin()
        } else if case .ready = viewModel.state {
            
            guard let videoUrl = viewModel.videoUrl else { return } // shouldn't happen
            
            viewModel.complete()
            
            let videoController = VideoViewController()
            videoController.viewModel = VideoViewModel(withVideoUrl: videoUrl)
            videoController.onDismiss = { [weak self] controller in
                self?.reset()
                controller.dismiss(animated: true, completion: nil)
            }
            self.present(videoController, animated: true, completion: nil)
        }
        
    }
}
