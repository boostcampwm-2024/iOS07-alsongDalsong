import SwiftUI

struct ASButtonStyle: ButtonStyle {
    var backgroundColor: Color
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(.doHyeon(size: 32))
        }
        .tint(.black)
        .frame(maxWidth: 345, maxHeight: 64)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: .asShadow, radius: 0, x: 5, y: 5)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 3))
    }
}

#Preview {
    Button {
        
    } label: {
        Image(systemName: "link")
        Text("hi")
    }
    .buttonStyle(ASButtonStyle(backgroundColor: Color(.asMint)))
}
