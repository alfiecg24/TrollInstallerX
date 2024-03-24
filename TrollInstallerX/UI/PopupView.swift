//
//  PopupView.swift
//  TrollInstallerX
//
//  Created by Alfie on 23/03/2024.
//

import SwiftUI

struct PopupView: View {
    @Binding var isShowingAlert: Bool
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white.opacity(0.1))
                    .frame(maxWidth: geometry.size.width / 1.2)
                    .frame(maxHeight: geometry.size.height / 1.75)
                    .transition(.scale)
                VStack {
                    Text("Unsandboxing")
                        .font(.system(size: 23, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                    Text("In order to avoid downloading the kernelcache for your device, TrollInstallerX can use the MacDirtyCow exploit to unsandbox and copy it instead. Press the button below to run the exploit - it is 100% reliable and all you have to do is press okay on an alert that will be presented.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)                    
                    Button(action: {
                        UIImpactFeedbackGenerator().impactOccurred()
//                        MacDirtyCow.unsandbox!()
                        grant_full_disk_access({ error in
                            if let error = error {
                                Logger.log("Failed to exploit with MacDirtyCow!")
                                NSLog("Failed to MacDirtyCow - \(error.localizedDescription)")
                            }
                            withAnimation {
                                isShowingAlert = false
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
                .frame(maxWidth: geometry.size.width / 1.35)
                .frame(maxHeight: geometry.size.height / 1.75)
                
            }
            
            .frame(maxWidth: geometry.size.width)
            .frame(maxHeight: geometry.size.height)
        }
    }
}
