//
//  SettingsView.swift
//  TrollInstallerX
//
//  Created by Alfie on 26/03/2024.
//

import SwiftUI

struct SettingsView: View {
    
    let device: Device
    
    @AppStorage("exploitFlavour") var exploitFlavour: String = "landa"
    @AppStorage("verbose") var verbose: Bool = false
        
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                UIImpactFeedbackGenerator().impactOccurred()
                let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                try? FileManager.default.removeItem(atPath: docsDir.path + "/kernelcache")
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: 225)
                        .frame(maxHeight: 40)
                        .foregroundColor(.white.opacity(0.2))
                        .shadow(radius: 10)
                    Text("Clear cached kernel")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                }
            })
            .padding()
            if smith.supports(device) || physpuppet.supports(device) {
                    Picker("Kernel exploit", selection: $exploitFlavour) {
                        Text("landa").foregroundColor(.white).tag("landa")
                        if smith.supports(device) {
                            Text("smith").foregroundColor(.white).tag("smith")
                        }
                        if physpuppet.supports(device) {
                            Text("physpuppet").foregroundColor(.white).tag("physpuppet")
                        }
                    }
                    .pickerStyle(.segmented)
                    .colorMultiply(.init(hex: 0x3dbcff))
                    .padding()
            }
            VStack {
                Toggle(isOn: $verbose, label: {
                    Text("Verbose logging")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                })
            }.padding()
        }
    }
}
