//
//  VideoViewModel.swift
//  VideoBalance
//
//  Created by Cristi Habliuc on 11/04/2019.
//  Copyright © 2019 Cristi Habliuc. All rights reserved.
//

import UIKit

class VideoViewModel: NSObject {
    
    var videoUrl: URL
    
    init(withVideoUrl videoUrl: URL) {
        self.videoUrl = videoUrl
        super.init()
    }
}
