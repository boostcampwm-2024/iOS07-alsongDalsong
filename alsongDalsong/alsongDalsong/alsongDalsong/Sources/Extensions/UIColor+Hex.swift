import UIKit

extension UIColor {
    convenience init?(hex: String?) {
        guard let hex = hex else {
            return nil
        }
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        let length = hexSanitized.count
        guard length == 6 || length == 8 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)

        var red, green, blue, alpha: CGFloat

        if length == 6 {
            red   = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blue  = CGFloat(rgbValue & 0x0000FF) / 255.0
            alpha = 1.0
        } else {
            red   = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            blue  = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(rgbValue & 0x000000FF) / 255.0
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
