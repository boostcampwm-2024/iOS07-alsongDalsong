import UIKit

class ASAvatarCircleView: UIView {
    init(image: UIImage, backgroundColor: UIColor = .asMint) {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        setup(image: image, backgroundColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(image: UIImage, backgroundColor: UIColor) {
        layer.cornerRadius = 100
        layer.masksToBounds = true
        layer.backgroundColor = backgroundColor.cgColor
        
        layer.borderWidth = 10
        layer.borderColor = UIColor.white.cgColor
        
        let imageView = UIImageView(image: image)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
}
