import SwiftUI

struct WaveFormWrapper: UIViewRepresentable {
    let data: URL
    let sampleCount: Int
    let circleColor: UIColor
    let highlightColor: UIColor
    
    func makeUIView(context: Context) -> WaveForm {
        let view = WaveForm(numOfColumns: sampleCount, circleColor: circleColor, highlightColor: highlightColor)
        
        return view
    }
    
    func updateUIView(_ uiView: WaveForm, context: Context) {
    }
}
