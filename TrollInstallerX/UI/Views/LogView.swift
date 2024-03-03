//
//  LogView.swift
//  Fugu15
//
//  Created by exerhythm on 29.03.2023.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct LogView: View {
    @StateObject var logger = Logger.shared
    
    @Binding var verboseLogsTemporary: Bool
    @Binding var verboseLogging: Bool
    
    let viewAppearanceDate = Date()
    
    var advanced: Bool {
        verboseLogging || verboseLogsTemporary
    }
    
    struct LogRow: View {
        @State var log: LogMessage
        @State var scrollViewFrame: CGRect
        
        @State var shown = false
        
        var index: Int
        var lastIndex: Int

        var isLast: Bool {
            index == lastIndex
        }
        
        var body: some View {
            GeometryReader { proxy2 in
                let k = k(for: proxy2.frame(in: .global).minY, in: scrollViewFrame)
                
                HStack {
                    switch log.type {
                    case .continuous:
                        ZStack {
                            let shouldShowCheckmark = !isLast
                            Image(systemName: "checkmark")
                                .opacity(shouldShowCheckmark ? 1 : 0)
                            LoadingIndicator(animation: .circleRunner, color: .white, size: .small)
                                .opacity(shouldShowCheckmark ? 0 : 1)
                        }
                        .offset(x: -4)
                    case .instant:
                        Image(systemName: "checkmark")
                    case .success:
                        Image(systemName: "lock.open")
                            .padding(.leading, 4)
                    case .error:
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.yellow)
                    }
                    Text(log.text)
                        .font(.system(isLast ? .body : .subheadline))
                        .foregroundColor(log.type == .error ? .yellow : .white)
                        .animation(.spring().speed(1.5), value: isLast)
                        .drawingGroup()
                    Spacer()
                }
                .opacity(k * (isLast ? 1 : 0.75))
                .blur(radius: 2.5 - k * 4)
                .foregroundColor(.white)
                .padding(.top, isLast ? 6 : 0)
                .animation(.spring().speed(1.5), value: isLast)
            }
            .opacity(shown ? 1 : 0)
            .onAppear {
                withAnimation(.spring().speed(3)) {
                    shown = true
                }
            }
        }
        
        func k(for y: CGFloat, in rect: CGRect) -> CGFloat {
            let h = rect.height
            let ry = rect.minY
            let relativeY = y - ry
            return 1 - (h - relativeY) / h
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { proxy1 in
                ScrollViewReader { reader in
                    ScrollView {
                        ZStack {
                            VStack {
                                Spacer()
                                    .frame(minHeight: proxy1.size.height)
                                LazyVStack(spacing: 24) {
                                    let frame = proxy1.frame(in: .global)
                                    ForEach(Array(logger.userFriendlyLogs.enumerated()), id: \.element.id) { (i,log) in
                                        LogRow(log: log, scrollViewFrame: frame, index: i, lastIndex: logger.userFriendlyLogs.count - 1)
                                    }
                                }
                                .padding(.horizontal, 32)
                                .padding(.bottom, 64)
                            }
                            .id("RegularLogs")
                            .frame(minHeight: proxy1.size.height)
                            .opacity(advanced ? 0 : 1)
                            .frame(maxHeight: advanced ? 0 : nil)
                            .animation(.spring(), value: advanced)
                            .onChange(of: logger.userFriendlyLogs) { newValue in
                                if !advanced {
                                    // give 0.5 seconds for a better feel
                                    if viewAppearanceDate.timeIntervalSinceNow < -0.5 {
                                        UISelectionFeedbackGenerator().selectionChanged()
                                    }
                                    
                                    withAnimation {
                                        reader.scrollTo("RegularLogs", anchor: .bottom)
                                    }
                                }
                            }
                            .onChange(of: advanced) { newValue in
                                if !newValue {
                                    withAnimation {
                                        reader.scrollTo(logger.userFriendlyLogs.last!.id, anchor: .top)
                                    }
                                }
                            }
                            
                            if advanced {
                                Text(logger.log)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: advanced ? .infinity : 0,
                                           maxHeight: advanced ? .infinity : 0)
                                    .tag("AdvancedText")
                                    .padding(.bottom, advanced ? 64 : 0)
                                    .padding(.horizontal, advanced ? 32 : 0)
                                    .opacity(advanced ? 1 : 0)
                                    .animation(.spring(), value: advanced)
                                    .onChange(of: logger.log) { newValue in
                                        if advanced {
                                            withAnimation(.spring().speed(1.5)) {
                                                reader.scrollTo("AdvancedText", anchor: .bottom)
                                            }
                                        }
                                    }
                                    .onChange(of: advanced) { newValue in
                                        if newValue {
                                            withAnimation(.spring().speed(1.5)) {
                                                reader.scrollTo("AdvancedText", anchor: .bottom)
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = logger.log
                        } label: {
                            Label("Copy to clipboard", systemImage: "doc.on.doc")
                        }
                    }
                }
            }
        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView(verboseLogsTemporary: .constant(false), verboseLogging: .constant(false))
            .background(Color.black)
    }
}
