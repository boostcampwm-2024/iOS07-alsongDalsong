import SwiftUI
import ASEntity
import Combine

struct HummingResultView: View {
    @State var amplitude: Float = 1.1
    var body: some View {
        ZStack {
            Color.asLightGray
                .ignoresSafeArea()
            
            VStack {
                //TODO: 정답 음악
                MusicResultView(albumImagePublisher: Just(Data())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher(),
                                musicName: "모조조조",
                                singerName: "이게 모죠?")
                    .padding(.bottom, 20)
                //임시 Just 처리
                
                //TODO: 제출된 허밍들
                ScrollView {
                    VStack {
                        ForEach(0 ..< 4) { index in
                            SpeechBubbleCell(alignment: index % 2 == 0 ? .left : .right,
                                             messageType: .music(Music(title: "Hello", artist: "허각")), amplitude: $amplitude)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                Button {
                    //TODO: 다음으로 or 완료
                } label: {
                    ASButtonWrapper(systemImageName: "play.fill",
                                    title: "다음으로",
                                    backgroundColor: .asMint)
                }
                .frame(width: 345, height: 64)
                .padding(.bottom, 77)
            }
        }
    }
}

struct MusicResultView: View {
    let albumImagePublisher: AnyPublisher<Data?, Error>
    let musicName: String
    let singerName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("정답은...")
                .font(.custom("Dohyeon-Regular", size: 24))
                .padding([.leading, .top], 16)
            
            HStack {
                //TODO: 요부분 ImagePublisher로 처리
                Image("mojojojo")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                VStack(alignment: .leading) {
                    Text(musicName)
                        .font(.custom("Dohyeon-Regular", size: 24))
                    
                    Text(singerName)
                        .font(.custom("Dohyeon-Regular", size: 24))
                        .foregroundStyle(.asLightGray)
                }
                .padding(.leading , 15)
            }
            .padding([.leading, .bottom], 19)
        }
        .frame(width: 345, height: 130, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .asShadow, radius: 0, x: 4, y: 4)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 3)
        }
        
    }
}

#Preview {
    HummingResultView()
}
