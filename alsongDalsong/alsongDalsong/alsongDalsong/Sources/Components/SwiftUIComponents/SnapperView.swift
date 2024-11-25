import SwiftUI
import ASEntity

struct SnapperView: View {
    private let size: CGSize
    private let modeInfos = Mode.allCases
    private let padding: CGFloat
    private let cardWidth: CGFloat
    private let spacing: CGFloat = 15.0
    private let maxSwipeDistance: CGFloat
    
    @Binding private var currentMode: Mode
    @State private var isDragging: Bool = false
    @State private var totalDrag: CGFloat = 0.0
    
    init(size: CGSize, currentMode: Binding<Mode>) {
        self.size = size
        self.cardWidth = size.width * 0.85
        self.padding = (size.width - cardWidth) / 2.0
        self.maxSwipeDistance = cardWidth + spacing
        self._currentMode = currentMode
    }
    
    var body: some View {
        let offset: CGFloat = maxSwipeDistance - (maxSwipeDistance * CGFloat(currentMode.Index))
        
        HStack(spacing: spacing) {
            ForEach(modeInfos, id: \.id) { card in
                ModeView(modeInfo: card, width: cardWidth)
                    .offset(x: isDragging ? totalDrag : 0)
                    .animation(.snappy(duration: 0.4, extraBounce: 0.2), value: isDragging)
            }
        }
        .padding(.horizontal, padding)
        .offset(x: offset, y: 0)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    totalDrag = value.translation.width
                }
                .onEnded { value in
                    isDragging = false
                    totalDrag = 0.0
                    
                    if (value.translation.width < -(cardWidth / 2.0) && self.currentMode.Index < modeInfos.count) {
                        self.currentMode = Mode.fromIndex(self.currentMode.Index + 1) ?? .harmony
                    }
                    if (value.translation.width > (cardWidth / 2.0) && self.currentMode.Index > 1) {
                        self.currentMode = Mode.fromIndex(self.currentMode.Index - 1) ?? .harmony
                    }
            }
        )
    }
}

#Preview {
    SnapperView(
        size: CGSize(
            width: 300,
            height: 400
        ),
        currentMode: .constant(.harmony)
    )
}
