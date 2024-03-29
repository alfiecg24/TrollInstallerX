import SwiftUI

struct LogView: View {
    @StateObject var logger = Logger.shared
    @Binding var installationFinished: Bool
    
    @AppStorage("verbose") var verbose: Bool = false
    
    let pipe = Pipe()
    let sema = DispatchSemaphore(value: 0)
    @State private var stderrString = ""
    @State private var stderrItems = [String]()
    
    @State var verboseID = UUID()
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    if verbose {
                        HStack {
                            Text(stderrString)
                                .font(.system(size: 10, weight: .regular, design: .monospaced))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.white)
                                .id(verboseID)
                            Spacer()
                        }
                        .frame(width: geometry.size.width)
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
                        
                        .onChange(of: geometry.size.height) { new in
                            DispatchQueue.main.async {
                                withAnimation {
                                    proxy.scrollTo(verboseID, anchor: .bottom)
                                }
                            }
                        }
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
                        .onChange(of: geometry.size.height) { newHeight in
                            DispatchQueue.main.async {
                                withAnimation {
                                    proxy.scrollTo(logger.logItems.last!.id, anchor: .bottom)
                                }
                            }
                        }
                        
                        .onChange(of: logger.logItems) { _ in
                            DispatchQueue.main.async {
//                                withAnimation {
                                    proxy.scrollTo(logger.logItems.last!.id, anchor: .bottom)
//                                }
                            }
                        }
                    }
                }
                
//                .frame(height: geometry.size.height)
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
