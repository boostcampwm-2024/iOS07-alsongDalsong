import UIKit

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage? {
        let size = self.size
        let transform = CGAffineTransform(rotationAngle: radians)
        let rotatedSize = CGRect(origin: .zero, size: size).applying(transform).integral.size
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: radians)
        self.draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()

        return rotatedImage
    }
}
