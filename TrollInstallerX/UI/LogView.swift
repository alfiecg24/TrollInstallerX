import SwiftUI

struct LogView: View {
    @StateObject var logger = Logger.shared
    @Binding var installationFinished: Bool
    @State private var stopScrolling = false
    
    @AppStorage("verbose") var verbose: Bool = false
    
    let pipe = Pipe()
    let sema = DispatchSemaphore(value: 0)
    @State private var stderrString = ""
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    if verbose {
                        HStack {
                            Text(stderrString)
                                .font(.system(size: 10, weight: .regular, design: .monospaced))
                                .multilineTextAlignment(.leading)
                                .onAppear {
                                    pipe.fileHandleForReading.readabilityHandler = { fileHandle in
                                        let data = fileHandle.availableData
                                        if data.isEmpty  { // end-of-file condition
                                            fileHandle.readabilityHandler = nil
                                            sema.signal()
                                        } else {
                                            stderrString += String(data: data,  encoding: .utf8)!
                                        }
                                    }
                                    // Redirect
                                    setvbuf(stdout, nil, _IONBF, 0)
                                    dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
                                }
                            Spacer()
                        }
                        .frame(width: geometry.size.width)
                    } else {
                        VStack(alignment: .leading) {
                            Spacer()
                            ForEach(logger.logItems) { log in
                                HStack {
                                    Label(
                                        title: {
                                            Text(log.message)
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                                .shadow(radius: 2)
                                        },
                                        icon: {
                                            Image(systemName: log.image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 12, height: 12)
                                                .padding(.trailing, 5)
                                        }
                                    )
                                    .foregroundColor(log.colour)
                                    .padding(.vertical, 5)
                                    .transition(AnyTransition.asymmetric(
                                        insertion: .move(edge: .bottom),
                                        removal: .move(edge: .top)
                                    ))
                                    Spacer()
                                }
                            }
                        }
                        //                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .onChange(of: logger.logItems) { _ in
                            withAnimation {
                                proxy.scrollTo(logger.logItems.last!.id, anchor: .bottom)
                            }
                        }
                        .onAppear {
                            DispatchQueue.global().async {
                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                    if logger.logItems.count > 0 {
                                        print("Most recent: \(logger.logItems.last!.message)")
                                    }
                                    if installationFinished && !stopScrolling {
                                        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { _ in
                                            print("Stopping scrolling")
                                            stopScrolling = true
                                        })
                                    }
                                    if !stopScrolling {
                                        if logger.logItems.count > 0 {
                                            withAnimation {
                                                proxy.scrollTo(logger.logItems.last!.id, anchor: .bottom)
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
            //            .frame(width: geometry.size.width, height: geometry.size.height)
            .contextMenu {
                Button {
                    UIPasteboard.general.string = verbose ? stderrString : Logger.shared.logString
                } label: {
                    Label("Copy to clipboard", systemImage: "doc.on.doc")
                }
            }
        }
    }
}
