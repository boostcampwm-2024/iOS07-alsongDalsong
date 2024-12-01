import UIKit

final class GuideIconView: UIView {
    private let imageView = UIImageView()
    private var animationCount = 0
    
    init(image: UIImage?, backgroundColor: UIColor?) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        setupImageView(image: image)
        applyCornerRadius(cornerRadius: 16)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView(image: UIImage?) {
        imageView.image = image
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func applyCornerRadius(cornerRadius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMaxXMaxYCorner
            ]
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.topLeft, .topRight, .bottomRight],
                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }

    private func animate(times: Int) {
        guard animationCount < times else { return }
        animationCount += 1
            
        transform = CGAffineTransform.identity
        transform = CGAffineTransform.identity
        UIView.animate(
            withDuration: 1.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.transform = CGAffineTransform.identity
                } completion: { [weak self] _ in
                    self?.animate(times: times)
                }
            }
        )
    }

    public func animateBounces(times: Int = 5) {
        animationCount = 0
        animate(times: times)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyCornerRadius(cornerRadius: layer.cornerRadius)
    }
}
