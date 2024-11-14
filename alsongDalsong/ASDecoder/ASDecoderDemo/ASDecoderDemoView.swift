import SwiftUI

struct ASDecoderDemoView: View {
    @StateObject private var viewModel = ASDecoderDemoViewModel()

    var body: some View {
        NavigationStack {
            }
            .navigationTitle("Decoding Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ASDecoderDemoView()
}
