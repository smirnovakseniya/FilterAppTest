import UIKit

final class ImageTransformingService: ImageTransformingServiceProtocol {
    
    func resize(image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }

    func fixedOrientation(image: UIImage?) -> UIImage? {
        guard let image = image, image.imageOrientation != .up else { return image }
        return resize(image: image, to: image.size)
    }

    func renderTransformedImage(from image: UIImage, scale: CGFloat, rotation: CGFloat) -> UIImage? {
        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: rotation)
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -center.x, y: -center.y)

        image.draw(in: CGRect(origin: .zero, size: size))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
