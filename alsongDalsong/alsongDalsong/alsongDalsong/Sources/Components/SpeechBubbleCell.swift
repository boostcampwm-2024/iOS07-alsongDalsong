import SwiftUI
import ASEntity

enum MessageType {
    //TODO: music(ASMusic) 과 같이 해당 타입의 데이터가 담길 수 있게
    case music(Music)
    case record(Record)
}

enum MessageAlignment {
    case left
    case right
}

struct SpeechBubbleCell: View {
    let alignment: MessageAlignment
    let messageType: MessageType
    @State var avatarURL: URL? = nil
    @Binding var amplitude: Float
    
    var body: some View {
        HStack {
            if alignment == .left {
                //ASAvatarCircleViewWrapper(imageURL: $avatarURL)
                Circle()
                    .frame(width: 80, height: 80)
            }
            speechBubble
            if alignment == .right {
                //ASAvatarCircleViewWrapper(imageURL: $avatarURL)
                Circle()
                    .frame(width: 80, height: 80)
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
                .frame(width: 255, height: height + 5)
                .foregroundStyle(Color.asShadow)
                .offset(x: 5, y: 5)
            
            BubbleShape(alignment: alignment)
                .frame(width: 250, height: height)
                .foregroundStyle(.white)
                .overlay(
                    BubbleShape(alignment: alignment)
                        .stroke(.black, lineWidth: 9)
                )
            
            ZStack(alignment: .leading) {
                BubbleShape(alignment: alignment)
                    .frame(width: 250, height: height)
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
                            
                            Text(music.artist ?? "")
                                .font(.custom("Dohyeon-Regular", size: 24))
                                .foregroundStyle(.asLightGray)
                        }
                        Spacer()
                    }
                    .frame(width: 250)
                    .offset(x: alignment == .left ? 20 : 5, y: -4)
                case .record(let record):
                    // 여기서 record를 줄 필요가 있을까요? ViewModel에서 해당 파일을 그냥 실행하면 될 거 같은데
                    HStack {
                        WaveFormViewWrapper(amplitude: $amplitude)
                    }
                    .frame(width: 220)
                    .offset(x: alignment == .left ? 20 : 5, y: -4)
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
            path.addLine(to: CGPoint(x: rect.maxX - 20, y: rect.minY + 25))
            path.addRoundedRect(in: CGRect(x: rect.minX - 10,
                                           y: rect.minY,
                                           width: rect.width - 10,
                                           height: rect.height - 10), cornerSize: CGSize(width: 15, height: 15))
        } else {
            path.move(to: CGPoint(x: rect.minX + 10, y: rect.minY + 25))
            path.addLine(to: CGPoint(x: rect.minX - 10, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + 50, y: rect.minY))
            path.addRoundedRect(in: CGRect(x: rect.minX + 10,
                                           y: rect.minY,
                                           width: rect.width - 10,
                                           height: rect.height - 10), cornerSize: CGSize(width: 15, height: 15))
        }
        return path
    }
}

#Preview {
    SpeechBubbleCell(alignment: .right,
                     messageType: .music(Music(title: "Hello", artist: "허각")),
                     amplitude: .constant(1.1))
}
