//
//  PersistenceHelperView.swift
//  TrollInstallerX
//
//  Created by Alfie on 30/03/2024.
//

import SwiftUI

struct PersistenceHelperView: View {
    @Binding var isShowingHelperAlert: Bool
    var body: some View {
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
                        withAnimation {
                            isShowingHelperAlert = false
                        }
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
                    withAnimation {
                        isShowingHelperAlert = false
                    }
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
    }
}
