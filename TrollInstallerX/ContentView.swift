//
//  ContentView.swift
//  TrollInstallerX
//
//  Created by Alfie on 10/02/2024.
//

import SwiftUI

func downloadManifestAsync(url: String, docsDir: String) async throws -> Int {
    let result = await withUnsafeContinuation { continuation in
        DispatchQueue.global().async {
            let resultCode = download_manifest(url, docsDir)
            continuation.resume(returning: resultCode)
        }
    }
    return Int(result)
}

func downloadKernelCacheAsync(url: String, kernelPath: String, docsDir: String) async throws -> Int {
    let result = await withUnsafeContinuation { continuation in
        DispatchQueue.global().async {
            let resultCode = download_kernelcache(url, kernelPath, docsDir)
            continuation.resume(returning: resultCode)
        }
    }
    return Int(result)
}

let pipe = Pipe()

enum InstallerPhase {
    case notStarted
    case findingURL
    case downloadingManifest
    case parsingManifest
    case downloadingKernel
    case decompressing
    case patchfinding
    case exploiting
    case escalating
    case installing
}

func phaseToString(_ phase: InstallerPhase) -> String {
    switch phase {
    case .notStarted:
        return "Waiting to start"
    case .findingURL:
        return "Finding IPSW URL"
    case .downloadingManifest:
        return "Downloading manifest"
    case .parsingManifest:
        return "Parsing manifest"
    case .downloadingKernel:
        return "Downloading kernelcache"
    case .decompressing:
        return "Decompressing kernelcache"
    case .patchfinding:
        return "Patchfinding kernel"
    case .exploiting:
        return "Exploiting kernel"
    case .escalating:
        return "Escalating privileges"
    case .installing:
        return "Installing TrollHelper"
    }
}

struct LogButtonView: View {
    @State private var isInstalling = false
    @State private var phase: InstallerPhase = .notStarted
    
    @Namespace var namespace
    
    @State var log = ""
    
    public func openConsolePipe () {
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(pipe.fileHandleForWriting.fileDescriptor,
             STDOUT_FILENO)
        pipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            let str = String(data: data, encoding: .utf8) ?? "<Non-UTF8 data of size \(data.count)>\n"
            DispatchQueue.main.async {
                log += str
            }
        }
    }
    
    var body: some View {
        VStack {
            
            if isInstalling {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(log)
                                .foregroundColor(.white)
                                .font(.system(size: 9, weight: .regular, design: .monospaced))
                                .multilineTextAlignment(.leading)
                                .padding()
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .transition(.scale)
                .frame(width: 350, height: 600)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.blue)
                        .frame(width: 350, height: 600)
                )
            } else {
                Button(action: {
                    withAnimation {
                        if #unavailable(iOS 17) {
                            isInstalling.toggle()
                            Task {
                                do {
                                    phase = .findingURL
                                    let url = try await getIPSWURL()
                                    guard url != nil else {
                                        print("Failed to find IPSW URL for \(getMachineName())/\(getBuildNumber())!")
                                        return
                                    }
                                    
                                    let fileManager = FileManager.default
                                    let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].path
                                    try? fileManager.removeItem(atPath: docsDir + "/BuildManifest.plist")
                                    try? fileManager.removeItem(atPath: docsDir + "/kernelcache")
                                    
                                    phase = .downloadingManifest
                                    var ret = try await downloadManifestAsync(url: url!, docsDir: docsDir)
                                    if ret != 0 {
                                        return
                                    }
                                    
                                    phase = .parsingManifest
                                    let kernelPath = getKernelPath(buildManifestPath: docsDir + "/BuildManifest.plist", model: getHWModel())
                                    guard kernelPath != nil else {
                                        print("Failed to find kernelcache file from manifest!")
                                        return
                                    }
                                    
                                    phase = .downloadingKernel
                                    ret = try await downloadKernelCacheAsync(url: url!, kernelPath: kernelPath!, docsDir: docsDir)
                                    if ret != 0 {
                                        print("Failed to download kernelcache file!")
                                        return
                                    }
                                    
                                    phase = .patchfinding
                                    patchfinder_test(docsDir + "/kernelcache")
                                    
                                } catch { }
                            }
                        }
                    }
                }) {
                    if #unavailable(iOS 17) {
                        Text("Install TrollStore")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.blue))
                            .onAppear {
                                openConsolePipe()
                            }
                    } else {
                        Text("Unsupported")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).opacity(0.5))
                    }
                    
                }
            }
        }
        .padding()
    }
}

struct ContentView: View {
    @State private var hasAnimated = false
    @State private var isInstalling = false
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack {
                    Image("TrollStore")
                        .resizable()
                        .imageScale(.large)
                        .cornerRadius(15)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 75)
                        .onAppear {
                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
                                withAnimation {
                                    hasAnimated.toggle()
                                }
                            })
                        }
                    if hasAnimated {
                        LogButtonView()
                        NavigationLink(destination: {
//                            SettingsView(isPresented: <#Binding<Bool>?#>)
                        }, label: {
                            Text("Preferences")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.blue))
                        })
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}

/*
 int puaf_pages = 512;
 if (cpuFamily == CPUFAMILY_ARM_TWISTER) { // A9
 puaf_pages = 128;
 if (@available(iOS 16.0, *)) {
 // sem_open does not like 128
 puaf_pages = 160;
 }
 } else if (cpuFamily == CPUFAMILY_ARM_TYPHOON) { // A8
 puaf_pages = 32;
 }
 
 puaf_method = puaf_landa
 
 kread_method = kread_sem_open
 kwrite_method = kwrite_sem_open
 
 staticHeadroom = 512
 
 getPhysicalMemorySize() > UInt64(5369221120)
 */
