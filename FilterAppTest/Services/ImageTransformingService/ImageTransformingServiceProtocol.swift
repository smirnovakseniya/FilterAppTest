import UIKit

protocol ImageTransformingServiceProtocol {
    func resize(image: UIImage, to size: CGSize) -> UIImage?
    func fixedOrientation(image: UIImage?) -> UIImage?
    func renderTransformedImage(from image: UIImage, scale: CGFloat, rotation: CGFloat) -> UIImage?
}
