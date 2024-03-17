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
    
    @State private var supportsOTA = false
    @State private var otaURL: URL? = nil
    
    @AppStorage("ignoreTrollHelperOTA") var ignoreTrollHelperOTA: Bool = false
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
                            Button(action: {
                                let generator = UINotificationFeedbackGenerator()
                                let fm = FileManager.default
                                let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                do {
                                    try fm.removeItem(at: docs.appendingPathComponent("kernelcache"))
                                    generator.notificationOccurred(.success)
                                } catch let e {
                                    print("Failed to remove kernelcache - \(e)")
                                    generator.notificationOccurred(.error)
                                }
                            }, label: {
                                VStack(alignment: .leading) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.secondary.opacity(0.2))
                                            .frame(maxHeight: 35)

                                        Text("Clear cached downloads")
                                    }
                                }
                            })
                            .padding(.bottom, 10)
                            
                            if supportsOTA {
                                Toggle("Ignore TrollHelperOTA", isOn: $ignoreTrollHelperOTA)
                            }
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
                .onAppear {
                    (supportsOTA, otaURL) = supportsTrollHelperOTA()
                }
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
