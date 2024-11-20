import UIKit
import SwiftUI

final class AvatarCircle: UIView {
    private var imageView: UIImageView?
    //TODO: 추후에 Data타입 또는 URL을 받아 이미지 표시
    private var imageName: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }
    
    private func setupImageView() {
        imageView = UIImageView()
        guard let imageView else {return}
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        layer.cornerRadius = 40
        layer.borderWidth = 4
        layer.borderColor = UIColor.white.cgColor
    }
    
    func setData(imageName: String) {
        //TODO: 임시로 systemImage 적용
        imageView?.image = UIImage(systemName: imageName)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let imageView {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
        }
    }
}

//struct AvatarCircleView: UIViewRepresentable {
//    //TODO: 추후에 Data타입 또는 URL을 받아 이미지 표시
//    // SpeechBubbleCell은 SwiftUI이므로 적용하기 위해 SwiftUI화
//    let imageName: String
//    
//    func makeUIView(context: Context) -> some AvatarCircle {
//        let avatarCircle = AvatarCircle(frame: .zero)
//        avatarCircle.setData(imageName: imageName)
//        return avatarCircle
//    }
//    
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        
//    }
//}
