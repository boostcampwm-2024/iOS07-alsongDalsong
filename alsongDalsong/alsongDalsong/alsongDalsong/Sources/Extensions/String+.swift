import UIKit

extension String {
    // Function to convert hex string to CGColor
    func hexToCGColor() -> CGColor? {
        // Remove the '#' if it exists
        var hexString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        // Ensure the hex string has the correct length
        guard hexString.count == 6 || hexString.count == 8 else {
            return nil
        }

        // Parse the hex string
        var hexInt: UInt64 = 0
        let scanner = Scanner(string: hexString)
        guard scanner.scanHexInt64(&hexInt) else {
            return nil
        }

        // Extract RGBA components
        let red = CGFloat((hexInt >> 24) & 0xFF) / 255.0
        let green = CGFloat((hexInt >> 16) & 0xFF) / 255.0
        let blue = CGFloat((hexInt >> 8) & 0xFF) / 255.0
        let alpha = hexString.count == 8 ? CGFloat(hexInt & 0xFF) / 255.0 : 1.0

        // Create a CGColor object
        return CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [red, green, blue, alpha])
    }
}
