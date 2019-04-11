//
//  Logger.swift
//  VideoBalance
//
//  Created by Cristi Habliuc on 11/04/2019.
//  Copyright © 2019 Cristi Habliuc. All rights reserved.
//

import UIKit

class Logger: NSObject {
    static func info(_ message: String) {
        print("Info: \(message)")
    }

    static func error(_ message: String) {
        print("Error: \(message)")
    }
}
