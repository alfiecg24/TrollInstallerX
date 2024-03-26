//
//  LaunchView.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

struct MainView: View {
    
    @State private var isInstalling = false
    @State private var logs = [LogItem(message: "Starting installation", type: .info), LogItem(message: "Performing installation", type: .info)]
    
    @State private var device: Device?
    
    @State private var isShowingMDCAlert = false
    
    @State private var isShowingSettings = false
    @State private var isShowingCredits = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    LinearGradient(colors: [Color(hex: 0x0482d1), Color(hex: 0x0566ed)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    VStack {
                        Image("Icon")
                            .resizable()
                            .cornerRadius(10)
                            .frame(maxWidth: 100, maxHeight: 100)
                            .shadow(radius: 10)
                        Text("TrollInstallerX")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        Text("By Alfie CG")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                        Text("iOS 14.0 - 16.6.1")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                        
                        if !isInstalling {
                            MenuView(isShowingSettings: $isShowingSettings, isShowingCredits: $isShowingCredits, isShowingMDCAlert: $isShowingMDCAlert)
                                .frame(maxWidth: geometry.size.width / 1.5, maxHeight: geometry.size.height / 4)
                                .transition(.scale)
                                .padding()
                                .shadow(radius: 10)
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.white.opacity(0.15))
                                .frame(maxWidth: isInstalling ? geometry.size.width / 1.2 : geometry.size.width / 2)
                                .frame(maxHeight: isInstalling ? geometry.size.height / 1.75 : 60)
                                .transition(.scale)
                                .shadow(radius: 10)
                            if isInstalling {
                                LogView()
                                    .padding()
                                    .frame(maxWidth: isInstalling ? geometry.size.width / 1.2 : geometry.size.width / 2)
                                    .frame(maxHeight: isInstalling ? geometry.size.height / 1.75 : 60)
                                    .contextMenu {
                                        Button {
                                            UIPasteboard.general.string = Logger.shared.logString
                                        } label: {
                                            Label("Copy to clipboard", systemImage: "doc.on.doc")
                                        }
                                    }
                            }
                            else {
                                Button(action: {
                                    if !isShowingCredits && !isShowingSettings && !isShowingMDCAlert {
                                        UIImpactFeedbackGenerator().impactOccurred()
                                        withAnimation {
                                            isInstalling.toggle()
                                        }
                                    }
                                }, label: {
                                        Text("Install")
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding()
                                })
                            }
                        }.padding()
                    }
                    .blur(radius: (isShowingMDCAlert || isShowingSettings || isShowingCredits) ? 10 : 0)
                }
                if isShowingMDCAlert {
                    PopupView(isShowingAlert: $isShowingMDCAlert, content: {
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
                                        .frame(width: geometry.size.width / 3)
                                        .frame(height: 50)
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
                        .padding()
                    })
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                if isShowingSettings {
                    PopupView(isShowingAlert: $isShowingSettings, content: {
                        SettingsView(device: device!)
                    })
                }
                
                if isShowingCredits {
                    PopupView(isShowingAlert: $isShowingCredits, content: {
                        CreditsView()
                    })
                }
            }
            .onChange(of: isInstalling) { _ in
                Task {
                    await doInstall(device!)
                }
            }
            .onAppear {
                device = initDevice()
                withAnimation {
                    isShowingMDCAlert = !checkForMDCUnsandbox() && MacDirtyCow.supports(device!)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
