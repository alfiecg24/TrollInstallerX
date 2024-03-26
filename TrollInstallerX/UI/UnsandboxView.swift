//
//  UnsandboxView.swift
//  TrollInstallerX
//
//  Created by Alfie on 26/03/2024.
//

import SwiftUI

struct UnsandboxView: View {
    @Binding var isShowingMDCAlert: Bool
    var body: some View {            
        VStack {
                Text("Unsandboxing")
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                Text("TrollInstallerX uses the 100% reliable MacDirtyCow exploit to unsandbox and copy the kernelcache. Press the button below to run the exploit - you only need to do this once.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    grant_full_disk_access({ error in
                        if let error = error {
                            Logger.log("Failed to exploit with MacDirtyCow!")
                            NSLog("Failed to MacDirtyCow - \(error.localizedDescription)")
                        }
                        withAnimation {
                            isShowingMDCAlert = false
                        }
                    })
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 175, height: 45)
                            .foregroundColor(.white.opacity(0.2))
                            .shadow(radius: 10)
                        Text("Unsandbox")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                    }
                })
                .padding(.vertical)
            }
    }
}
