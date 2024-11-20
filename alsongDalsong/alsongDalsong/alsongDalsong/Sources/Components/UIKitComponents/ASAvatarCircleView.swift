import UIKit
import SwiftUI
import ASCacheKit

final class ASAvatarCircleView: UIView {
    private var imageView = UIImageView()
    private let cacheManager = ASCacheManager()
    
    init(backgroundColor: UIColor = .asMint) {
        super.init(frame: .zero)
        setup(backgroundColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(backgroundColor: UIColor) {
        layer.cornerRadius = 100
        layer.masksToBounds = true
        layer.backgroundColor = backgroundColor.cgColor
        
        layer.borderWidth = 10
        layer.borderColor = UIColor.white.cgColor
        
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setImage(imageURL: URL) {
        Task {
            guard let imageData = await cacheManager.loadCache(from: imageURL, cacheOption: .both) else {
                imageView.image = UIImage(systemName: "person.fill")
                return
            }
            imageView.image = UIImage(data: imageData)
        }
    }
}

struct ASAvatarCircleViewWrapper: UIViewRepresentable {
    let backgroundColor: UIColor = UIColor.asMint
    @Binding var imageURL: URL?

    // MARK: - UIViewRepresentable Methods
    func makeUIView(context: Context) -> ASAvatarCircleView {
        let avatarView = ASAvatarCircleView(backgroundColor: backgroundColor)
        if let imageURL = imageURL {
            avatarView.setImage(imageURL: imageURL)
        } else {
            if let imagePath = Bundle.main.path(forResource: "mojojojo", ofType: "png") {
                let imageURL = URL(fileURLWithPath: imagePath)
                avatarView.setImage(imageURL: imageURL)
            }
        }
        return avatarView
    }

    func updateUIView(_ uiView: ASAvatarCircleView, context: Context) {
        if let imageURL = imageURL {
            uiView.setImage(imageURL: imageURL)
        } else {
            //TODO: 이미지 URL 받아서 setImage 호출
        }
    }
}
