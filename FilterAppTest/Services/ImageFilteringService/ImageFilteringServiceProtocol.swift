import UIKit

protocol ImageFilteringServiceProtocol {
    func applyFilter(to image: UIImage, filter: FilterModel, intensity: Float) -> UIImage?
}
