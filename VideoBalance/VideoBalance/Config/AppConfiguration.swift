//
//  AppConfiguration.swift
//  VideoBalance
//
//  Created by Cristi Habliuc on 11/04/2019.
//  Copyright © 2019 Cristi Habliuc. All rights reserved.
//

import Foundation

/// Keep the app's configuration here
struct AppConfiguration {
    /// You can configure the URL string in the build settings and then reference it in the Info.plist file under the key `ONYX_ARCHIVE_URL`
    static let archiveUrl: URL = {
        guard let valueFromBundle = Bundle.main.object(forInfoDictionaryKey: "ONYX_ARCHIVE_URL") as? String else {
            fatalError("The URL can't be found in info.plist. Make sure it's set up correctly in the build settings and referenced in info.plist")
        }
        
        guard let url = URL(string: valueFromBundle) else {
            fatalError("The URL from the build settings and referenced in info.plist is not a valid URL")
        }
        
        return url
    }()
    
    /// The path to where we should save the temporary files (the archive and the unzipped video)
    static let localDirectoryUrl = FileManager.default.temporaryDirectory.appendingPathComponent("files")
    
    static let defaultAnimDuration: TimeInterval = 0.35
    
}
