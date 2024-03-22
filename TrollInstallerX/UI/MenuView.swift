//
//  MenuView.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white.opacity(0.15))
                VStack {
                    Button(action: {
                        UIImpactFeedbackGenerator().impactOccurred()
                    }, label: {
                        HStack {
                            Label(
                                title: {
                                    Text("Settings")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                },
                                icon: { Image(systemName: "gear")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 22, height: 22)
                                        .padding(.trailing, 5)
                                }
                            )
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    })
                    .padding()
                    .frame(maxHeight: geometry.size.height / 2)
                    
                    Divider()
                    
                    Button(action: {
                        UIImpactFeedbackGenerator().impactOccurred()
                    }, label: {
                        HStack {
                            Label(
                                title: {
                                    Text("Credits")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                },
                                icon: { Image(systemName: "info.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 22, height: 22)
                                        .padding(.trailing, 5)
                                }
                            )
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    })
                    .padding()
                    .frame(maxHeight: geometry.size.height / 2)
                }
                .padding()
            }
        }
    }
}

#Preview {
    MenuView()
}
 
