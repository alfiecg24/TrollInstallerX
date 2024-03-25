import SwiftUI

struct LogView: View {
    @StateObject var logger = Logger.shared
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ScrollViewReader { proxy in
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
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    .onChange(of: logger.logItems) { _ in
                        withAnimation {
                            proxy.scrollTo(logger.logItems[0].id, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
                            if logger.logItems.count > 0 {
                                withAnimation {
                                    proxy.scrollTo(logger.logItems[0].id, anchor: .bottom)
                                }
                            }
                        })
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
