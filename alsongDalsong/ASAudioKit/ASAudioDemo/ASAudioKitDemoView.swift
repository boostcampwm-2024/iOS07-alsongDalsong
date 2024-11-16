import SwiftUI

struct ASAudioKitDemoView: View {
    @StateObject var asAudioKitDemoViewModel: ASAudioKitDemoViewModel = ASAudioKitDemoViewModel()
    
    var body: some View {
        VStack {
            Button {
                asAudioKitDemoViewModel.recordButtonTapped()
            } label: {
                if asAudioKitDemoViewModel.isRecording {
                    Image(systemName: "pause")
                        .resizable()
                        .foregroundStyle(.red)
                        .frame(width: 100, height: 100)
                } else {
                    Image(systemName: "record.circle")
                        .resizable()
                        .foregroundStyle(.red)
                        .frame(width: 100, height: 100)
                }
            }
            .padding(.bottom, 20)
            
            if let file = asAudioKitDemoViewModel.recordedFile {
                Button {
                    asAudioKitDemoViewModel.startPlaying(recoredFile: file, playType: .full)
                    // 최초 녹음 시에 안들림
                } label: {
                    Image(systemName: "play.fill")
                        .resizable()
                        .foregroundStyle(.tint)
                        .frame(width: 50, height: 50)
                }
                .padding(.bottom, 10)
                
                ProgressBar(progress: Float(asAudioKitDemoViewModel.playedTime) / Float(asAudioKitDemoViewModel.getDuration(recordedFile: file) ?? 0))
                    .frame(height: 2)
            }
            else {
                Image(systemName: "play.slash")
                    .resizable()
                    .foregroundStyle(.gray)
                    .frame(width: 50, height: 50)
            }
        }
        .padding()
    }
}

struct ProgressBar: View {
    var progress: Float
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray)
                
                Rectangle()
                    .fill(Color.cyan)
                    .frame(width: CGFloat(self.progress) * geometry.size.width)
            }
        }
    }
}

#Preview {
    ASAudioKitDemoView()
}
