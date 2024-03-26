//
//  PopupView.swift
//  TrollInstallerX
//
//  Created by Alfie on 23/03/2024.
//

import SwiftUI

struct PopupView<Content: View>: View {
    @Binding var isShowingAlert: Bool
    let shouldAllowDismiss: Bool
    var content: Content
    
    init(isShowingAlert: Binding<Bool>, shouldAllowDismiss: Bool = true, @ViewBuilder content: () -> Content) {
        self._isShowingAlert = isShowingAlert
        self.shouldAllowDismiss = shouldAllowDismiss
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                // Allows for tapping anywhere to dismiss
                RoundedRectangle(cornerRadius: 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white.opacity(0.000001))
                    .ignoresSafeArea()
                    .onTapGesture {
                        if shouldAllowDismiss {
                            withAnimation {
                                isShowingAlert.toggle()
                            }
                        }
                    }
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white.opacity(0.1))
                    .frame(maxWidth: geometry.size.width / 1.2)
                    .frame(maxHeight: geometry.size.height / 1.75)
                    .transition(.scale)
                
                
                VStack {
                    // Custom view
                    content
                        .frame(maxWidth: geometry.size.width / 1.35)
                        .frame(maxHeight: geometry.size.height / 1.75)
                }
                .frame(maxWidth: geometry.size.width / 1.2)
                .frame(maxHeight: geometry.size.height / 1.75)
                .transition(.scale)
                
            }
        }
    }
}
