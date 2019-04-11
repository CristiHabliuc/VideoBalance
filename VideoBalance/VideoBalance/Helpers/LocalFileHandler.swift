//
//  ArchiveHandler.swift
//  VideoBalance
//
//  Created by Cristi Habliuc on 11/04/2019.
//  Copyright © 2019 Cristi Habliuc. All rights reserved.
//

import UIKit
import Zip

protocol Archiver {
    func unzip(fileAt url: URL, then callback: @escaping (URL?, Error?) -> Void)
}

class LocalFileHandler: NSObject, Archiver {
    static let shared = LocalFileHandler()
    
    private override init() {
        super.init()
    }
    
    func unzip(fileAt url: URL, then callback: @escaping (URL?, Error?) -> Void) {
        let destinationUrl = AppConfiguration.localDirectoryUrl
        do {
            // unzip the archive
            try Zip.unzipFile(url, destination: destinationUrl, overwrite: true, password: nil)
            
            // now find the video in it (there might be some other hidden files in it)
            let files = try FileManager.default.contentsOfDirectory(atPath: destinationUrl.path)
            for file in files {
                if file.hasSuffix("mp4") {
                    // found it
                    let fileUrl = destinationUrl.appendingPathComponent(file)
                    callback(fileUrl, nil)
                    return
                }
            }
            
            // no video file was found
            callback(nil, nil)
        } catch {
            callback(nil, error)
        }
    }
    
    /// Deletes the downloaded and unzipped files from the folder we created
    func cleanup() {
        do {
            try FileManager.default.removeItem(at: AppConfiguration.localDirectoryUrl)
            Logger.info("Deleted files.")
        } catch {
            Logger.error("Can't clean up: \(error.localizedDescription)")
        }
    }
}
