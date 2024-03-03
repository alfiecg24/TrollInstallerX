//
//  AboutView.swift
//  Evyrest
//
//  Created by Lakhan Lothiyi on 30/12/2022.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) var openURL
    
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    let contributors = [
        ("opa334", "http://github.com/opa334"), /* TrollStore */
        ("felix-pb", "http://github.com/felix-pb"), /* kfd */
        ("kok3shidoll", "http://github.com/kok3shidoll"), /* kfd stuff */
        ("dhinakg", "http://github.com/dhinakg"), /* memory hogger */
        ("staturnz", "http://github.com/staturnzz"), /* patchfinding */
        ("sourcelocation", "http://github.com/sourcelocation"), /* UI */
    ]
    
    var body: some View {
        VStack {
            VStack {
                Button(action: {
                    openURL(URL(string: "https://github.com/alfiecg24/TrollInstallerX")!)
                }) {
                    HStack {
                        Spacer()
                        Image("github")
                        Text("Source code")
                        Spacer()
                    }
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 32)
                }
                Button(action: {
                    openURL(URL(string: "https://github.com/alfiecg24/TrollInstallerX/LICENSE")!)
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "scroll")
                        Text("License")
                        Spacer()
                    }
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 32)
                }
                Button(action: {
                    openURL(URL(string: "https://discord.gg/jb")!)
                }) {
                    HStack {
                        Spacer()
                        Image("discord")
                        Text("Discord")
                        Spacer()
                    }
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 32)
                }
            }
            .padding(.vertical)
            
            LazyVGrid(columns: columns) {
                ForEach(contributors, id: \.0) { contributor in
                    // FIXME
//                    Link(destination: URL(string: contributor.1)!) {
                        HStack {
                            Text(contributor.0)
                            Image(systemName: Locale.characterDirection(forLanguage: Locale.current.languageCode ?? "") == .rightToLeft ? "chevron.left" : "chevron.right")
                        }
                        .padding(.vertical, 4)
//                    }
                }
            }
            .font(.footnote)
            .opacity(0.6)
            .padding(.bottom)
            .padding(.horizontal, 16)
            
            
            Text("Special thanks to the people above")
                .fixedSize()
                .font(.footnote)
                .opacity(0.6)
                .padding(.bottom, 5)
            
            Group {
                Text("TrollInstallerX \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")\nOS: \(ProcessInfo.processInfo.operatingSystemVersionString)")
            }
            .fixedSize()
            .font(.footnote)
            .opacity(0.6)
        }
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
//        .frame(maxHeight: 600)
    }
}


struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        InstallerView()
    }
}
