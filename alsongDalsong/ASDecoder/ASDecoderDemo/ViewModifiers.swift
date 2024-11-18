import SwiftUI

struct PrimaryGradientBackgroundModifier: ViewModifier {
    var textColor: Color

    func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.cyan, .green, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct SecondaryGradientBackgroundModifier: ViewModifier {
    var textColor: Color

    func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.red, .purple, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct GrayBackgroundModifier: ViewModifier {
    var textColor: Color

    func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .padding()
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    func primaryGradientBackground(textColor: Color = .black) -> some View {
        modifier(PrimaryGradientBackgroundModifier(textColor: textColor))
    }

    func secondaryGradientBackground(textColor: Color = .white) -> some View {
        modifier(SecondaryGradientBackgroundModifier(textColor: textColor))
    }

    func grayBackground(textColor: Color = .white) -> some View {
        modifier(GrayBackgroundModifier(textColor: textColor))
    }
}
