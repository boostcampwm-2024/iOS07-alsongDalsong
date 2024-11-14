import SwiftUI

class ToastViewModel: ObservableObject {
    @Published var isPresented: Bool = false
    @Published var message: String = ""

    func present(message: String) {
        isPresented = true
        self.message = message

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isPresented = false
        }
    }
}

struct ToastView: View {
    @ObservedObject var vm: ToastViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.teal.opacity(0.2))
                .shadow(radius: 10)
            Text(vm.message)
                .font(.headline)
                .foregroundColor(.black)
                .padding()
        }
        .frame(width: 280, height: 40)
        .padding(.bottom, 10)
    }
}
