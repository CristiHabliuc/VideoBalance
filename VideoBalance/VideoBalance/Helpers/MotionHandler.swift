//
//  MotionHandler.swift
//  VideoBalance
//
//  Created by Cristi Habliuc on 11/04/2019.
//  Copyright © 2019 Cristi Habliuc. All rights reserved.
//

import UIKit
import CoreMotion

/// Handles all the motion data and updates
class MotionHandler: NSObject {
    
    // MARK: - Public properties
    
    /// Use this singleton to use this class
    static let shared = MotionHandler()
    
    /// Query this to find out if the functionality is available on the device
    var canHandleMotionEvents: Bool {
        return motionManager.isDeviceMotionAvailable
    }
    
    /// Set this value to true or false to activate or deactivate the handler
    var isUpdating: Bool = false {
        willSet {
            guard newValue != isUpdating else { return }
            setUpdatesActive(newValue)
        }
    }
    
    /// Set this to the callback that will get updated every time we poll the tilt
    var onUpdate: ((_ degrees: Double) -> Void)?
    
    // MARK: - Private properties
    
    /// The motion manager
    fileprivate var motionManager = CMMotionManager()
    
    fileprivate let kDeviceMotionUpdateInterval: TimeInterval = 0.1
    
    private override init() {
        super.init()
    }
    
    fileprivate func setUpdatesActive(_ active: Bool) {
        if active {
            motionManager.deviceMotionUpdateInterval = kDeviceMotionUpdateInterval
            let queue = OperationQueue.main
//            motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: queue) { [weak self] (motion, error) in
            motionManager.startDeviceMotionUpdates(to: queue) { [weak self] (motion, error) in
                guard let self = self else { return }
                if let motion = motion {
                    let pitch = motion.attitude.pitch
                    let maxPitch = (90.0 / 180.0) * Double.pi
                    let zGravity = motion.gravity.z
                    
                    var degrees = pitch * 180/Double.pi
                    if zGravity > 0 {
                        // the device is facing downwards, we need to adjust it
                        degrees = 90 + ((maxPitch - pitch) * 180/Double.pi)
                    }
                    
                    self.onUpdate?(degrees)
                }
            }
            Logger.info("Started device motion updates.")
        } else {
            motionManager.stopDeviceMotionUpdates()
            Logger.info("Stopped device motion updates.")
        }
    }
}
