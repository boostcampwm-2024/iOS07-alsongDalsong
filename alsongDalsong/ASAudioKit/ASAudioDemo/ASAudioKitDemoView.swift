import SwiftUI

struct ASAudioKitDemoView: View {
    @StateObject var viewModel: ASAudioKitDemoViewModel = ASAudioKitDemoViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isRecording {
                AudioVisualizerViewWrapper(amplitude: $viewModel.recorderAmplitude)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
            }
            
            Button {
                viewModel.recordButtonTapped()
            } label: {
                if viewModel.isRecording {
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
            
            if let file = viewModel.recordedFile {
                Button {
                    viewModel.startPlaying(recoredFile: file, playType: .full)
                } label: {
                    Image(systemName: "play.fill")
                        .resizable()
                        .foregroundStyle(.tint)
                        .frame(width: 50, height: 50)
                }
                .padding(.bottom, 10)
                
                ProgressBar(progress: Float(viewModel.playedTime) / Float(viewModel.getDuration(recordedFile: file) ?? 0))
                    .frame(height: 2)
                    .padding(.bottom, 10)
                
                AudioVisualizerViewWrapper(amplitude: $viewModel.playerAmplitude)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
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
