//
//  Logger.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

enum LogType {
    case success
    case warning
    case error
    case info
}

struct LogItem: Identifiable, Equatable {
    let message: String
    let type: LogType
    let date: Date = Date()
    var id = UUID()
    
    var image: String {
        switch self.type {
        case .success:
            return "checkmark"
        case .warning:
            return "exclamationmark.triangle"
        case .error:
            return "xmark"
        case .info:
            return "info"
        }
    }
    
    var colour: Color {
        switch self.type {
        case .success:
            return .init(hex: 0x08d604)
        case .warning:
            return .yellow
        case .error:
            return .red
        case .info:
            return .white
        }
    }
}

class Logger: ObservableObject {
    @Published var logString: String = ""
    @Published var logItems: [LogItem] = [LogItem]()
    
    static var shared = Logger()
    
    static func log(_ logMessage: String, type: LogType? = .info) {
        let newItem = LogItem(message: logMessage, type: type ?? .info)
        print(logMessage)
        UIImpactFeedbackGenerator().impactOccurred()
        DispatchQueue.main.async {
            shared.logItems.append(newItem)
            shared.logString.append(logMessage + "\n")
            shared.logItems.sort(by: { $0.date < $1.date })
        }
    }
}
