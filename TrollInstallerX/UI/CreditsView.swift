//
//  CreditsView.swift
//  TrollInstallerX
//
//  Created by Alfie on 26/03/2024.
//

import SwiftUI

struct Credit {
    var name: String
    var link: URL
}

let credits: [Credit] = [
    Credit(name: "opa334", link: URL(string: "https://x.com/opa334dev")!),
    Credit(name: "Kaspersky", link: URL(string: "https://securelist.com/operation-triangulation-the-last-hardware-mystery/111669/")!),
    Credit(name: "wh1te4ever", link: URL(string: "https://github.com/wh1te4ever")!),
    Credit(name: "xina520", link: URL(string: "https://x.com/xina520")!),
    Credit(name: "staturnz", link: URL(string: "https://github.com/staturnzz")!),
    Credit(name: "DTCalabro", link: URL(string: "https://github.com/DTCalabro")!),
    
    Credit(name: "felib-pb", link: URL(string: "https://github.com/felix-pb")!),
    Credit(name: "kok3shidoll", link: URL(string: "https://github.com/kok3shidoll")!),
    Credit(name: "Zhuowei", link: URL(string: "https://github.com/zhuowei")!),
    Credit(name: "dhinakg", link: URL(string: "https://github.com/dhinakg")!),
    Credit(name: "aaronp613", link: URL(string: "https://x.com/aaronp613")!),
    Credit(name: "JJTech", link: URL(string: "https://github.com/JJTech0130")!)
]

struct CreditsView: View {
    var body: some View {
        
        VStack {
            Text("Credits")
                .font(.system(size: 23, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding()
            HStack {
                VStack {
                    
                    VStack(spacing: 3) {
                        ForEach(0..<(credits.count / 2)) { index in
                            CreditRow(credit: credits[index])
                        }
                    }
                }
                
                VStack {
                    
                    VStack(spacing: 3) {
                        ForEach((credits.count / 2)..<credits.count) { index in
                            CreditRow(credit: credits[index])
                        }
                    }
                }
            }
        }
    }
}

struct CreditRow: View {
    let credit: Credit
    
    var body: some View {
        HStack {
            Link(destination: credit.link) {
                HStack {
                    Text(credit.name)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
    }
}


#Preview {
    CreditsView()
}
