//
//  Logger.swift
//  Fugu15
//
//  Created by exerhythm on 29.03.2023.
//

import SwiftUI

struct LogMessage: Equatable, Identifiable {
    var id = UUID()
    var text: String
    var type: LogType
    
    enum LogType {
        case instant
        case continuous
        case success
        case error
    }
}

class Logger: ObservableObject {
    @Published var userFriendlyLogs: [LogMessage] = []
    @Published var log: String = ""
    
    static var shared = Logger()
    
    /**
     *  Add a string to log view.
     *
     * - Parameter text: The text to display
     * - Parameter isContinuous: Determines whether the action is instant or continuous, and if a spinner next to text should be shown
     * - Parameter isStatus: Should the log be displayed to users who have "Simple Logs" option turned on
     */
    static func log(_ obj: Any, type: LogMessage.LogType = .continuous, isStatus: Bool = false) {
        let text = String(describing: obj)
        print(text)
        shared.log += "\n\(text)"
        if isStatus {
            shared.userFriendlyLogs.append(.init(text: NSLocalizedString(text, comment: "Installation Status"), type: type))
        }
    }
}
