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
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalToConstant: 18),
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
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveLinear,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.4,
                    delay: 0.1
                ) {
                    self.transform = CGAffineTransform.identity
                } completion: { [weak self] _ in
                    self?.animate(times: times)
                }
            }
        )
    }

    func animateBounces(times: Int = 10) {
        animationCount = 0
        animate(times: times)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyCornerRadius(cornerRadius: layer.cornerRadius)
    }
}
