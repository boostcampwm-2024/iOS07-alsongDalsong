import SwiftUI

enum MessageType {
    //TODO: music(ASMusic) 과 같이 해당 타입의 데이터가 담길 수 있게
    case music
    case record
}

enum MessageAlignment {
    case left
    case right
}

struct SpeechBubbleCell: View {
    let alignment: MessageAlignment
    let messageType: MessageType
    let message: String
    
    var body: some View {
        HStack {
            if alignment == .left {
                AvatarCircleView(imageName: "person")
                    .frame(width: 80, height: 80)
                    .padding(.leading, 10)
            }
            speechBubble
            if alignment == .right {
                AvatarCircleView(imageName: "person")
                    .frame(width: 80, height: 80)
                    .padding(.leading, 10)
            }
        }
    }
    
    @ViewBuilder
    private var speechBubble: some View {
        var height: CGFloat {
            if messageType == .music {
                return 90
            }
            return 64
        }
        
        ZStack {
            BubbleShape(alignment: alignment)
                .frame(width: 255, height: height + 5)
                .foregroundStyle(Color("asShadow"))
                .offset(x: alignment == .right ? -5 : 5, y: 5)
            
            BubbleShape(alignment: alignment)
                .frame(width: 250, height: height)
                .foregroundStyle(.blue)
                .overlay(
                    BubbleShape(alignment: alignment)
                        .stroke(.black, lineWidth: 9)
                )
            
            ZStack {
                BubbleShape(alignment: alignment)
                    .frame(width: 250, height: height)
                    .foregroundStyle(.white)
                
                // TODO: 해당 위치에 messageType에 따라 음악을 보여줄건지, record를 보여줄건지 결정
                Text(message)
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
                                           y: rect.minY, width: rect.width - 10,
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
    SpeechBubbleCell(alignment: .right, messageType: .music, message: "HELLO")
}
