//
//  CreditsView.swift
//  TrollInstallerX
//
//  Created by Alfie on 26/03/2024.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        VStack {
            Text("Credits")
                .font(.system(size: 23, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding()
            
            VStack(spacing: 3) {
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
    }
}

#Preview {
    CreditsView()
}
