//
//  VideoBalanceTests.swift
//  VideoBalanceTests
//
//  Created by Cristi Habliuc on 11/04/2019.
//  Copyright © 2019 Cristi Habliuc. All rights reserved.
//

import XCTest
@testable import VideoBalance

class VideoBalanceCoreTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDownloadAndUnzip() {
        let expectation = XCTestExpectation(description: "Download apple.com home page")
        
        RemoteDownloader.shared.downloadArchive { url, error in
            XCTAssert(error == nil, "There was an error downloading: \(error?.localizedDescription ?? "unknown")")
            
            guard let url = url else {
                XCTAssert(false, "destination (download) url is nil")
                return
            }
            
            LocalFileHandler.shared.unzip(fileAt: url, then: { (url, error) in
                XCTAssert(error == nil, "Could not unzip file: \(error?.localizedDescription ?? "unknown error")")
                
                XCTAssert(url != nil, "unzipped file url is nil")
                
                print("unzipped file at \(url!)")
                
                expectation.fulfill()
            })
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
}
