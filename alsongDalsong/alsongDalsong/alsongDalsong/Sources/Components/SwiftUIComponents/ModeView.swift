import SwiftUI
import ASEntity

struct ModeView: View {
    let modeInfo: Mode
    let width: CGFloat
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.asSystem)
                .cornerRadius(12)
                .shadow(color: .asShadow, radius: 0, x: 5, y: 5)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 3))
            VStack {
                Text(modeInfo.title)
                    .font(.doHyeon(size: 32))
                    .padding(.top, 16)
                Image(modeInfo.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()
                Text(modeInfo.description)
                    .font(.doHyeon(size: 20))
                    .padding(.horizontal)
                    .minimumScaleFactor(0.01)
                Spacer()
            }
            
        }
        .frame(width: width)
    }
}
