import SwiftUI
import ASEntity
import Combine

enum MessageType {
    //TODO: music(ASMusic) 과 같이 해당 타입의 데이터가 담길 수 있게
    case music(Music)
    case record(ASEntity.Record)
}

enum MessageAlignment {
    case left
    case right
}

struct SpeechBubbleCell: View {
    let alignment: MessageAlignment
    let messageType: MessageType
    let imagePublisher: AnyPublisher<Data?, Error>
    let name: String
    @State private var isVisible = false
    
    var body: some View {
        HStack {
            if alignment == .left {
                ProfileView(imagePublisher: imagePublisher,
                            name: name,
                            isHost: false)
                .frame(width: 75, height: 75)
                .padding(.trailing, 10)
            }
            if isVisible {
                speechBubble
                    .transition(.move(edge: alignment == .left ? .leading : .trailing))
                    .animation(.easeInOut(duration: 1.0), value: isVisible)
            }
            if alignment == .right {
                ProfileView(imagePublisher: imagePublisher,
                            name: name,
                            isHost: false)
                .frame(width: 75, height: 75)
                .padding(.leading, 10)
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
    
    @ViewBuilder
    private var speechBubble: some View {
        var height: CGFloat {
            switch messageType {
            case .music(_):
                return 90
            case .record(_):
                return 64
            }
        }
        
        ZStack {
            BubbleShape(alignment: alignment)
                .frame(width: 235, height: height + 5)
                .foregroundStyle(Color.asShadow)
                .offset(x: 5, y: 5)
            
            BubbleShape(alignment: alignment)
                .frame(width: 230, height: height)
                .foregroundStyle(.white)
                .overlay(
                    BubbleShape(alignment: alignment)
                        .stroke(.black, lineWidth: 9)
                )
            
            ZStack(alignment: .leading) {
                BubbleShape(alignment: alignment)
                    .frame(width: 230, height: height)
                    .foregroundStyle(.white)
                
                switch messageType {
                case .music(let music):
                    HStack {
                        //TODO: 요부분 ImagePublisher로 처리
                        Image("mojojojo")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        VStack(alignment: .leading) {
                            Text(music.title ?? "")
                                .font(.custom("Dohyeon-Regular", size: 24))
                                .lineLimit(2)
                            
                            Text(music.artist ?? "")
                                .font(.custom("Dohyeon-Regular", size: 24))
                                .foregroundStyle(.asLightGray)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .frame(width: 220)
                    .offset(x: alignment == .left ? 30 : 5, y: -4)
                case .record(let record):
                    // 여기서 record를 줄 필요가 있을까요? ViewModel에서 해당 파일을 그냥 실행하면 될 거 같은데
                    HStack {
                        WaveFormViewWrapper()
                    }
                    .frame(width: 215)
                    .offset(x: alignment == .left ? 22 : -7, y: -4)
                }
            }
        }
    }
}

struct BubbleShape: Shape {
    let alignment: MessageAlignment
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if alignment == .right {
            path.move(to: CGPoint(x: rect.maxX - 40, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - 20, y: rect.minY + 12))
            path.addLine(to: CGPoint(x: rect.maxX - 40, y: rect.minY))
            path.addRoundedRect(in: CGRect(x: rect.minX - 10,
                                           y: rect.minY,
                                           width: rect.width - 10,
                                           height: rect.height - 10), cornerSize: CGSize(width: 12, height: 12))
        } else {
            path.addRoundedRect(in: CGRect(x: rect.minX + 20,
                                           y: rect.minY,
                                           width: rect.width - 10,
                                           height: rect.height - 10), cornerSize: CGSize(width: 12, height: 12))
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + 40, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + 20, y: rect.minY + 12))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }
        path.closeSubpath()
        return path
    }
}
