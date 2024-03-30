//
//  TrollInstallerXApp.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

@main
struct TrollInstallerXApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                // Force status bar to be white
                .preferredColorScheme(.dark)
        }
    }
}
