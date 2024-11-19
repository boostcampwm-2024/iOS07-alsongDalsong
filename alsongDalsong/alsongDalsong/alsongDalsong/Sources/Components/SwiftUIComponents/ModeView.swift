import SwiftUI

struct ModeView: View {
    let modeInfo: ModeInfo
    let width: CGFloat
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .cornerRadius(12)
                .shadow(color: .asShadow, radius: 0, x: 5, y: 5)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 3))
            VStack {
                Text(modeInfo.title)
                    .font(.custom("DoHyeon-Regular", size: 32))
                    .padding(.top, 16)
                Image(modeInfo.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding()
                Text(modeInfo.description)
                    .font(.custom("DoHyeon-Regular", size: 16))
                    .padding(.horizontal)
                Spacer()
            }
            
        }
        .frame(width: width)
    }
}
