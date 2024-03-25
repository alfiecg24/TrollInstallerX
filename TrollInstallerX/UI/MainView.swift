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
    
    @State private var isShowingAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    LinearGradient(colors: [Color(hex: 0x00A8FF), Color(hex: 0x0C6BFF)], startPoint: .topLeading, endPoint: .bottomTrailing)
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
                            MenuView()
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
                                    UIImpactFeedbackGenerator().impactOccurred()
                                    withAnimation {
                                        isInstalling.toggle()
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
                    .blur(radius: isShowingAlert ? 7.5 : 0)
                }
                if isShowingAlert {
                    PopupView(isShowingAlert: $isShowingAlert)
                        .frame(width: geometry.size.width, height: geometry.size.height)
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
                    isShowingAlert = !checkForMDCUnsandbox() && MacDirtyCow.supports(device!)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
