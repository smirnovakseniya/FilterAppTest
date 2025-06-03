import UIKit
import CoreImage

final class ImageFilteringService: ImageFilteringServiceProtocol {

    private lazy var context: CIContext = {
        let options: [CIContextOption: Any] = [
            .workingColorSpace: NSNull(),
            .outputColorSpace: NSNull()
        ]
        return CIContext(options: options)
    }()
    
    private var cachedCIImage: CIImage?
    private var cachedUIImage: UIImage?
    private var cachedFilter: CIFilter?
    private var lastFilterName: String = ""

    func applyFilter(to image: UIImage, filter: FilterModel, intensity: Float) -> UIImage? {
        let ciImage: CIImage
        if cachedUIImage === image, let cached = cachedCIImage {
            ciImage = cached
        } else {
            guard let newCIImage = CIImage(image: image) else { return image }
            ciImage = newCIImage
            cachedCIImage = newCIImage
            cachedUIImage = image
        }
        
        let ciFilter: CIFilter
        if lastFilterName == filter.ciFilterName, let cached = cachedFilter {
            ciFilter = cached
        } else {
            guard let newFilter = CIFilter(name: filter.ciFilterName) else { return image }
            ciFilter = newFilter
            cachedFilter = newFilter
            lastFilterName = filter.ciFilterName
        }

        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        if filter.inputKey != "", ciFilter.inputKeys.contains(filter.inputKey) {
            ciFilter.setValue(intensity, forKey: filter.inputKey)
        }
        
        switch filter.name {
        case .original:
            return image

        case .sepiaTone, .contrast, .gamma, .sharpen, .saturation:
            break

        case .vignette:
            ciFilter.setValue(1.0, forKey: kCIInputRadiusKey)
        }

        guard let outputImage = ciFilter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage)
    }
}
