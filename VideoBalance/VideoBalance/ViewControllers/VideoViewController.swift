//
//  VideoViewController.swift
//  VideoBalance
//
//  Created by Cristi Habliuc on 11/04/2019.
//  Copyright © 2019 Cristi Habliuc. All rights reserved.
//

import UIKit
import Player
import AVFoundation

class VideoViewController: UIViewController {
    
    @IBOutlet var closeButton: UIButton!
    
    @IBOutlet var videoContainer: UIView!
    
    var viewModel: VideoViewModel? {
        didSet {
            getReadyAndPlay()
        }
    }
    
    /// This is called when the user taps the close button. You should dismiss the controller at this point
    var onDismiss: ((VideoViewController) -> Void)?

    fileprivate var player = Player()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurePlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        player.view.frame = self.videoContainer.bounds
        getReadyAndPlay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player.stop()
    }
    
    fileprivate func configurePlayer() {
        self.addChild(player)
        self.videoContainer.addSubview(player.view)
        self.player.didMove(toParent: self)
    }

    fileprivate func getReadyAndPlay() {
        guard let viewModel = viewModel else { return }
        let videoUrl = viewModel.videoUrl
        
        guard isViewLoaded else { return }
        
        guard player.playbackState != .playing else { return }
        
        player.url = videoUrl
        player.playbackLoops = true
        player.playFromBeginning()
    }
    
    @IBAction func handleCloseButtonTap(_ sender: Any) {
        onDismiss?(self)
    }
    
}
