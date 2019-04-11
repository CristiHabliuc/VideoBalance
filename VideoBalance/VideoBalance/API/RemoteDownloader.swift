//
//  RemoteDownloader.swift
//  VideoBalance
//
//  Created by Cristi Habliuc on 11/04/2019.
//  Copyright © 2019 Cristi Habliuc. All rights reserved.
//

import Foundation
import Alamofire

protocol Downloader {
    func downloadArchive(then callback: @escaping (URL?, Error?) -> Void)
}

class RemoteDownloader: Downloader {
    
    static let shared = RemoteDownloader()
    
    func downloadArchive(then callback: @escaping (URL?, Error?) -> Void) {
        let url = AppConfiguration.archiveUrl
        let filename = url.lastPathComponent
        let destinationDirUrl = AppConfiguration.localDirectoryUrl
        let destinationPath = destinationDirUrl.appendingPathComponent(filename)

        let destination: DownloadRequest.Destination = { _, _ in
            return (destinationPath, [.removePreviousFile, .createIntermediateDirectories])
        }
        let urlRequest = URLRequest(url: url)
        let downloadRequest = AF.download(urlRequest, interceptor: nil, to: destination)
        downloadRequest.response { response in
            if let error = response.error {
                callback(nil, error)
            } else {
                callback(destinationPath, nil)
            }
        }
    }
}
