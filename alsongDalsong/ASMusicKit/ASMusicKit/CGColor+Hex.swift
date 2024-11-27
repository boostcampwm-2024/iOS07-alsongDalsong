import CoreGraphics

extension CGColor {
    func toHex() -> String? {
        guard let components = components, components.count >= 3 else {
            return nil
        }
        let r = components[0]
        let g = components[1]
        let b = components[2]

        var a: CGFloat = 1.0
        if components.count >= 4 {
            a = components[3]
        }

        if a != 1.0 {
            return String(format: "#%02X%02X%02X%02X",
                          Int(r * 255),
                          Int(g * 255),
                          Int(b * 255),
                          Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X",
                          Int(r * 255),
                          Int(g * 255),
                          Int(b * 255))
        }
    }
}
