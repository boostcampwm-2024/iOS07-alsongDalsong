import UIKit

extension String {
    func hexToCGColor() -> CGColor? {
        var hexString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        guard hexString.count == 6 || hexString.count == 8 else {
            return nil
        }

        var hexInt: UInt64 = 0
        let scanner = Scanner(string: hexString)
        guard scanner.scanHexInt64(&hexInt) else {
            return nil
        }

        let red, green, blue, alpha: CGFloat
        if hexString.count == 8 {
            red = CGFloat((hexInt >> 24) & 0xFF) / 255.0
            green = CGFloat((hexInt >> 16) & 0xFF) / 255.0
            blue = CGFloat((hexInt >> 8) & 0xFF) / 255.0
            alpha = CGFloat(hexInt & 0xFF) / 255.0
        } else {
            red = CGFloat((hexInt >> 16) & 0xFF) / 255.0
            green = CGFloat((hexInt >> 8) & 0xFF) / 255.0
            blue = CGFloat(hexInt & 0xFF) / 255.0
            alpha = 1.0
        }

        return CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [red, green, blue, alpha])
    }
}
