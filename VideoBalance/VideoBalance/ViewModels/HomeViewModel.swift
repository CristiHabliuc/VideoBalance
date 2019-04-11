//
//  HomeViewModel.swift
//  VideoBalance
//
//  Created by Cristi Habliuc on 11/04/2019.
//  Copyright © 2019 Cristi Habliuc. All rights reserved.
//

import UIKit

class HomeViewModel: NSObject {
    
    /// These are all the possible states of the app
    enum State: Equatable {
        case initial
        case downloading
        case downloaded
        case error(message: String)
        case unzipped
        case waiting // waiting for the correct tilt
        case ready
        case finished // moving the model in this state disables the move updates
    }
    
    /// Tells you which state we're in
    private(set) var state: State = .initial {
        didSet {
            stateChangedCallback?(state)
        }
    }
    
    /// The video url that was unzipped
    fileprivate(set) var videoUrl: URL?
    
    /// The min angle that the slider is tracking
    let minimumTrackedAngle: Double = 40
    /// The max angle that the slider is tracking
    let maximumTrackedAngle: Double = 100
    /// The min angle that is accepted in order to move the model into the .ready state
    let minimumAcceptedAngle: Double = 65
    /// The max angle that is accepted in order to move the model into the .ready state
    let maximumAcceptedAngle: Double = 70

    // MARL: - Private properties
    
    /// This callback will be called every time there's a state change (only when the state is different than what it was)
    fileprivate var stateChangedCallback: ((State) -> Void)?

    /// This callback will be called every time the motion detected has changed angle. Use this to update the slider in the UI, for example, but don't rely on it for state change. Use `bindToStateChange(_:)` instead
    fileprivate var tiltAngleChangedCallback: ((Double) -> Void)?

    // MARK: - Public methods
    
    /// Bind this callback to be notified of state changes
    func bindToStateChange(_ callback: ((State) -> Void)?) {
        stateChangedCallback = callback
    }
    
    /// Bind this callback to be notified of tilt angle changes
    /// The values returned will always be reported in this interval: minimumTrackedAngle...maximumTrackedAngle. This is capped so you don't have to double check in the UI
    func bindToTiltAngleChange(_ callback: ((Double) -> Void)?) {
        tiltAngleChangedCallback = callback
    }
    
    /// Call this method to begin the download of the file
    func begin() {
        self.state = .downloading
        Logger.info("Beginning scenario...")
        
        RemoteDownloader.shared.downloadArchive { (destinationUrl, error) in
            guard error == nil else {
                self.state = .error(message: error!.localizedDescription)
                return
            }
            
            guard let destinationUrl = destinationUrl else {
                self.state = .error(message: "Destination URL not found")
                return
            }
            
            DispatchQueue.main.async {
                self.state = .downloaded
                
                Logger.info("Downloaded file. It's here: \(destinationUrl)")

                // next step
                self.unzip(destinationUrl)
            }
        }
    }
    
    /// Call this when everything is done (i.e. the user is going to the movie)
    func complete() {
        stopListeningToDeviceMovements()
        Logger.info("Completed scenario.")
        state = .finished
    }
    
    /// Call this to reset everything and do a clean up
    func reset() {
        stopListeningToDeviceMovements()

        // clean up the folder
        LocalFileHandler.shared.cleanup()
        
        // update the state to complete reset
        state = .initial
        Logger.info("Reset.")
    }
    
    // MARK: - Private methods
    
    fileprivate func unzip(_ url: URL) {
        LocalFileHandler.shared.unzip(fileAt: url) { (videoUrl, error) in
            guard error == nil else {
                self.state = .error(message: error!.localizedDescription)
                return
            }
            
            guard let videoUrl = videoUrl else {
                self.state = .error(message: "Video URL not found")
                return
            }
            
            DispatchQueue.main.async {
                self.videoUrl = videoUrl
                self.state = .unzipped
                
                Logger.info("Unzipped video. It's here: \(videoUrl)")

                // we can then safely move directly into waiting
                self.state = .waiting
                self.startListeningToDeviceMovements()
            }
        }
    }
    
    fileprivate func startListeningToDeviceMovements() {
        let handler = MotionHandler.shared
        handler.onUpdate = { degrees in
            var capped = max(degrees, self.minimumTrackedAngle)
            capped = min(capped, self.maximumTrackedAngle)
            
            // notify any interested object
            self.tiltAngleChangedCallback?(capped)
            
            // decide if we should change state
            if capped >= self.minimumAcceptedAngle &&
                capped <= self.maximumAcceptedAngle {
                // change state to ready
                self.state = .ready
            } else {
                self.state = .waiting
            }
        }
        handler.isUpdating = true
        Logger.info("Listening to device movements...")

    }
    
    fileprivate func stopListeningToDeviceMovements() {
        let handler = MotionHandler.shared
        handler.onUpdate = nil
        handler.isUpdating = false
        Logger.info("Stopped listening to device movements.")
    }
    
}
