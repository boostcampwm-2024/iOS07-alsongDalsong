import ASRepository
import SwiftUI

struct LobbyView: View {
//    @StateObject var viewModel: LobbyViewModel
    @ObservedObject var viewModel: LobbyViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .rotationEffect(.degrees(-90))
                        .tint(.black)
                }
                Spacer()
                Text(viewModel.roomNumber)
                    .foregroundStyle(.gray)
                    .font(.custom("DoHyeon-Regular", size: 48))
            }
            .font(.title)
            .padding()
            HStack(spacing: 15) {
                ForEach(viewModel.players) { player in
                    ProfileView(imageURL: player.avatarUrl, name: player.nickname)
                }
            }
            .padding()
            GeometryReader { reader in
                SnapperView(size: reader.size, cards: viewModel.cards)
            }
            Button {
                
            } label: {
                Image(systemName: "link")
                Text("초대코드")
            }
            .buttonStyle(ASButtonStyle(backgroundColor: Color(.asYellow)))
            Button {
                print("초대코드 복사 완료")
            } label: {
                Image(systemName: "play.fill")
                Text("시작하기!")
            }
            .buttonStyle(ASButtonStyle(backgroundColor: Color(.asMint)))
        }
        .background(Color.asLightGray)
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct SnapperView: View {
    let size: CGSize
    let cards: [ModeInfo]
    private let padding: CGFloat
    private let cardWidth: CGFloat
    private let spacing: CGFloat = 15.0
    private let maxSwipeDistance: CGFloat
    
    @State private var currentCardIndex: Int = 1
    @State private var isDragging: Bool = false
    @State private var totalDrag: CGFloat = 0.0
    
    init(size: CGSize, cards: [ModeInfo]) {
        self.size = size
        self.cards = cards
        self.cardWidth = size.width * 0.85
        self.padding = (size.width - cardWidth) / 2.0
        self.maxSwipeDistance = cardWidth + spacing
    }
    
    var body: some View {
        let offset: CGFloat = maxSwipeDistance - (maxSwipeDistance * CGFloat(currentCardIndex))
        LazyHStack(spacing: spacing) {
            ForEach(cards, id: \.id) { card in
                CardView(card: card, width: cardWidth)
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
                    totalDrag = 0.0
                    isDragging = false
                    
                    if (value.translation.width < -(cardWidth / 2.0) && self.currentCardIndex < cards.count) {
                        self.currentCardIndex = self.currentCardIndex + 1
                    }
                    if (value.translation.width > (cardWidth / 2.0) && self.currentCardIndex > 1) {
                        self.currentCardIndex = self.currentCardIndex - 1
                    }
            }
        )
    }
}

struct ModeInfo: Identifiable {
    var id: UUID = UUID()
    let title: String
    let imageName: String
    let description: String
}

struct CardView: View {
    let card: ModeInfo
    let width: CGFloat
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .cornerRadius(12)
                .shadow(color: .asShadow, radius: 0, x: 4, y: 4)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 3))
            VStack {
                Text(card.title)
                    .font(.custom("DoHyeon-Regular", size: 32))
                    .padding(.top, 16)
                Image(card.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding()
                Text(card.description)
                    .font(.custom("DoHyeon-Regular", size: 16))
                    .padding(.horizontal)
                Spacer()
            }
            
        }
        .frame(width: width)
    }
}

#Preview {
    LobbyView(viewModel: LobbyViewModel(mainRepository: MainRepository(roomNumber: "ASDKFJ")))
}
