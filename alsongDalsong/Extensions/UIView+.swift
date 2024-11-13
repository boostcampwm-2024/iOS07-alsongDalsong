import UIKit

extension UIView {
    /// 버튼에 지정된 그림자를 추가하는 메서드
    func setShadow(color: UIColor = .asShadow, width: CGFloat = 4, height: CGFloat = 4, radius: CGFloat = 0, opacity: Float = 1) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowRadius = radius
    }
}
