//
//  SettingsView.swift
//  Fugu15
//
//  Created by exerhythm on 02.04.2023.
//

import SwiftUI

struct SettingsView: View {
    
    var totalJailbreaks: Int = 0
    var successfulJailbreaks: Int = 0
    
    @AppStorage("verboseLogging") var verboseLogs: Bool = false
    @AppStorage("usePerfPatchfinder") var usePerfPatchfinder: Bool = false
    
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>?) {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .init(named: "AccentColor")
        self._isPresented = isPresented ?? .constant(true)
    }
    
    var body: some View {
        VStack {
                VStack {
                    VStack(spacing: 20) {
                        VStack(spacing: 10) {
                            Toggle("Verbose logging", isOn: $verboseLogs)
                            Toggle("Force offline patchfinder", isOn: $usePerfPatchfinder)
                        }
                        .foregroundColor(.white)
                    }
                    .foregroundColor(.accentColor)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    
                    Divider()
                        .background(Color.white)
                        .padding(.horizontal, 32)
                        .opacity(0.25)
                    VStack(spacing: 6) {
                        Text("Offline patchfinding should be used if there isn't an IPSW available for your version")
                            .font(.footnote)
                            .opacity(0.6)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 2)
                }
                .foregroundColor(.white)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InstallerView()
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
