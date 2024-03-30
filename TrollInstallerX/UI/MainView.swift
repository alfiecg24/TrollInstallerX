//
//  LaunchView.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

struct MainView: View {
    
    @State private var isInstalling = false
    
    @State private var device: Device = initDevice()
    
    @State private var isShowingMDCAlert = false
    @State private var isShowingOTAAlert = false
    @State private var isShowingHelperAlert = false
    
    @State private var isShowingSettings = false
    @State private var isShowingCredits = false
    
    @State private var installedSuccessfully = false
    @State private var installationFinished = false
    
    // Best way to show the alert midway through doInstall()
    @ObservedObject var helperView = HelperAlert.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    LinearGradient(colors: [Color(hex: 0x0482d1), Color(hex: 0x0566ed)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    VStack {
                        VStack {
                            Image("Icon")
                                .resizable()
                                .cornerRadius(22)
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
                        }
                        .padding(.vertical)
                        
                        if !isInstalling {
                            MenuView(isShowingSettings: $isShowingSettings, isShowingCredits: $isShowingCredits, isShowingMDCAlert: $isShowingMDCAlert, isShowingOTAAlert: $isShowingOTAAlert, device: device)
                                .frame(maxWidth: geometry.size.width / 1.2, maxHeight: geometry.size.height / 4)
                                .transition(.scale)
                                .padding()
                                .shadow(radius: 10)
                                .disabled(!device.isSupported)
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.white.opacity(0.15))
                                .frame(maxWidth: geometry.size.width / 1.2)
                                .frame(maxHeight: isInstalling ? geometry.size.height / 1.75 : 60)
                                .transition(.scale)
                                .shadow(radius: 10)
                            if isInstalling {
                                LogView(installationFinished: $installationFinished)
                                    .padding()
                                    .frame(maxWidth: geometry.size.width / 1.2)
                                    .frame(maxHeight: geometry.size.height / 1.75)
                            }
                            else {
                                Button(action: {
                                    if !isShowingCredits && !isShowingSettings && !isShowingMDCAlert && !isShowingOTAAlert {
                                        UIImpactFeedbackGenerator().impactOccurred()
                                        withAnimation {
                                            isInstalling.toggle()
                                        }
                                    }
                                }, label: {
                                    Text(device.isSupported ? "Install TrollStore" : "Unsupported")
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            .foregroundColor(device.isSupported ? .white : .secondary)
                                            .padding()
                                            .frame(maxWidth: geometry.size.width / 1.2)
                                            .frame(maxHeight: 60)
                                })
                                .frame(maxWidth: geometry.size.width / 1.2)
                                .frame(maxHeight: 60)
                            }
                        }
                        .padding()
                        .disabled(!device.isSupported)
                        
                        
                        }
                        .blur(radius: (isShowingMDCAlert || isShowingOTAAlert || isShowingSettings || isShowingCredits || helperView.showAlert) ? 10 : 0)
                    }
                }
                if isShowingOTAAlert {
                    PopupView(isShowingAlert: $isShowingOTAAlert, content: {
                        TrollHelperOTAView(arm64eVersion: .constant(false))
                    })
                }
                if isShowingMDCAlert {
                    PopupView(isShowingAlert: $isShowingMDCAlert, shouldAllowDismiss: false, content: {
                        UnsandboxView(isShowingMDCAlert: $isShowingMDCAlert)
                    })
                }
                if isShowingSettings {
                    PopupView(isShowingAlert: $isShowingSettings, content: {
                        SettingsView(device: device)
                    })
                }
                
                if isShowingCredits {
                    PopupView(isShowingAlert: $isShowingCredits, content: {
                        CreditsView()
                    })
                }
            
            if helperView.showAlert {
                PopupView(isShowingAlert: $isShowingHelperAlert, shouldAllowDismiss: false, content: {
                        ScrollView {
                            VStack {
                                Text("Persistence helper")
                                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("If you already have one installed, scroll to the bottom.")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            VStack(spacing: 20) {
                                ForEach(getCandidates(), id: \.self) { candidate in
                                    Button(action: {
                                        UserDefaults.standard.setValue(candidate.bundleIdentifier, forKey: "persistenceHelper")
                                        isShowingHelperAlert = false
                                    }, label: {
                                        HStack {
                                            if let image = candidate.icon {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .frame(width: 44, height: 44)
                                                    .cornerRadius(10)
                                            } else {
                                                Image(systemName: "gear")
                                                    .resizable()
                                                    .frame(width: 44, height: 44)
                                                    .cornerRadius(10)
                                            }
                                            Text(candidate.displayName)
                                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                                .foregroundColor(.white)
                                                .padding(.leading)
                                            Spacer()
                                        }
                                    })
                                }
                                Divider()
                                Button(action: {
                                    UserDefaults.standard.setValue("", forKey: "persistenceHelper")
                                    isShowingHelperAlert = false
                                }, label: {
                                    HStack {
                                        Image(systemName: "xmark.circle")
                                            .resizable()
                                            .frame(width: 44, height: 44)
                                            .cornerRadius(10)
                                            .foregroundColor(.red)
                                        Text("No persistence helper")
                                            .font(.system(size: 20, weight: .regular, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.leading)
                                        Spacer()
                                    }
                                })
                                .padding(.bottom)
                            }
                        }
                    })
                }
            }
            // Hacky, but it works
            .onChange(of: helperView.showAlert) { new in
                if new {
                    isShowingHelperAlert = true
                }
            }
            .onChange(of: isShowingHelperAlert) { new in
                if !new {
                    helperView.showAlert = false
                }
            }
            .onChange(of: isInstalling) { _ in
                Task {
                    installedSuccessfully = await doInstall(device)
                    installationFinished = true
                }
            }
            .onAppear {
                if device.isSupported {
                    withAnimation {
                        isShowingOTAAlert = device.supportsOTA
                        if !isShowingOTAAlert { isShowingMDCAlert = !checkForMDCUnsandbox() && MacDirtyCow.supports(device) }
                    }
                }
            }
            .onChange(of: isShowingOTAAlert) { _ in
                if !checkForMDCUnsandbox() && MacDirtyCow.supports(device) && !isShowingOTAAlert && device.supportsOTA { // User has just dismissed alert
                    withAnimation {
                        isShowingMDCAlert = true
                    }
                }
            }
        }
    }


#Preview {
    MainView()
}
