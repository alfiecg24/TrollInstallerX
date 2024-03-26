//
//  TrollHelperOTAView.swift
//  TrollInstallerX
//
//  Created by Alfie on 26/03/2024.
//

import SwiftUI

struct TrollHelperOTAView: View {
    @Binding var arm64eVersion: Bool
    var body: some View {
            VStack {
                Text("TrollHelperOTA")
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                Text("Your device is compatible with TrollHelperOTA - a 100% reliable installation method that does not require you to sideload an app. You can tap outside this alert to dismiss this, or press the button below to install via OTA.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    UIApplication.shared.open(URL(string: "https://api.jailbreaks.app/troll" + (arm64eVersion ? "64e" : ""))!)
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 175, height: 45)
                            .foregroundColor(.white.opacity(0.2))
                            .shadow(radius: 10)
                        Text("Take me there")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                })
                .padding(.vertical)
            }
    }
}
