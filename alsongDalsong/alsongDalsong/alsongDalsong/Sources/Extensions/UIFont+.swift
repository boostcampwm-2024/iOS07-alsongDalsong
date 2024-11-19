import UIKit

enum FontName: String {
    case dohyeon = "Dohyeon-Regular"
}

extension UIFont {
    static func font(_ style: FontName = .dohyeon, ofSize size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: style.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return customFont
    }

    static func font(_ style: FontName = .dohyeon, forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        let size = UIFont.preferredFont(forTextStyle: textStyle).pointSize
        guard let customFont = UIFont(name: style.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return customFont
    }
}
