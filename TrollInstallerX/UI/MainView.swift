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
                        @State var exploitFlavour: String = (UserDefaults.standard.string(forKey: "exploitFlavour") ?? (physpuppet.supports(device!) ? "physpuppet" : "landa"))
                        @State var verbose: Bool = UserDefaults.standard.bool(forKey: "verbose")
                        @State var ignoreTrollHelperOTA: Bool = UserDefaults.standard.bool(forKey: "ignoreTrollHelperOTA")
                        
                        VStack(spacing: 10) {
                            // NEED CUSTOM EXPLOIT PICKER
                            if smith.supports(device!) || physpuppet.supports(device!) {
//                                Picker("Kernel exploit", selection: $exploitFlavour) {
//                                    Text("landa").tag("landa")
//                                    if smith.supports(device!) {
//                                        Text("smith").tag("smith")
//                                    }
//                                    if physpuppet.supports(device!) {
//                                        Text("physpuppet").tag("physpuppet")
//                                    }
//                                }
//                                .onChange(of: exploitFlavour) { _ in
//                                    print("Switch")
//                                    UserDefaults.standard.setValue(exploitFlavour, forKey: "exploitFlavour")
//                                }
                            }
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
                            .padding(.horizontal)
                            Toggle(isOn: $verbose, label: {
                                Text("Verbose logging")
                                    .font(.system(size: 17, weight: .regular, design: .rounded))
                                    .foregroundColor(.white)
                            })
                            .padding(.horizontal)
                            .onChange(of: verbose) { _ in
                                UserDefaults.standard.setValue(verbose, forKey: "verbose")
                            }
                            Toggle(isOn: $ignoreTrollHelperOTA, label: {
                                Text("Ignore TrollHelperOTA")
                                    .font(.system(size: 17, weight: .regular, design: .rounded))
                                    .foregroundColor(.white)
                            })
                            .padding(.horizontal)
                            .onChange(of: ignoreTrollHelperOTA) { _ in
                                UserDefaults.standard.setValue(ignoreTrollHelperOTA, forKey: "ignoreTrollHelperOTA")
                            }
                        }
                    })
                }
                
                if isShowingCredits {
                    PopupView(isShowingAlert: $isShowingCredits, content: {
                        VStack {
                            Text("Credits")
                                .font(.system(size: 23, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                            Text("TrollInstallerX wouldn't have been possible without these developers:")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 5) {
                                HStack {
                                    Link(destination: URL(string: "https://x.com/opa334dev")!, label: {
                                        HStack {
                                            Text("opa334")
                                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                        }
                                    })
                                    .padding()
                                    Link(destination: URL(string: "https://github.com/felix-pb")!, label: {
                                        HStack {
                                            Text("felib-pb")
                                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                        }
                                    })
                                    .padding()
                                }
                                HStack {
                                    Link(destination: URL(string: "https://securelist.com/operation-triangulation-the-last-hardware-mystery/111669/")!, label: {
                                        HStack {
                                            Text("Kaspersky")
                                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                        }
                                    })
                                    .padding()
                                    Link(destination: URL(string: "https://github.com/kok3shidoll")!, label: {
                                        HStack {
                                            Text("kok3shidoll")
                                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                        }
                                    })
                                    .padding()
                                }
                                HStack {
                                    Link(destination: URL(string: "https://github.com/wh1te4ever")!, label: {
                                        HStack {
                                            Text("wh1te4ever")
                                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                        }
                                    })
                                    .padding()
                                    Link(destination: URL(string: "https://github.com/zhuowei")!, label: {
                                        HStack {
                                            Text("Zhuowei")
                                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                        }
                                    })
                                    .padding()
                                }
                                HStack {
                                    Link(destination: URL(string: "https://x.com/xina520")!, label: {
                                        HStack {
                                            Text("xina520")
                                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                        }
                                    })
                                    .padding()
                                    Link(destination: URL(string: "https://github.com/dhinakg")!, label: {
                                        HStack {
                                            Text("dhinakg")
                                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                        }
                                    })
                                    .padding()
                                }
                                HStack {
                                    Link(destination: URL(string: "https://github.com/staturnzz")!, label: {
                                        HStack {
                                            Text("staturnz")
                                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                        }
                                    })
                                    .padding()
                                    Link(destination: URL(string: "https://x.com/aaronp613")!, label: {
                                        HStack {
                                            Text("aaronp613")
                                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                        }
                                    })
                                    .padding()
                                }
                            }
                        }
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
