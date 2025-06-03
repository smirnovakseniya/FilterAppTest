import UIKit
import CoreImage

final class PreviewGenerator: PreviewGeneratorProtocol {
    private let filterService: ImageFilteringServiceProtocol

    init(filterService: ImageFilteringServiceProtocol) {
        self.filterService = filterService
    }

    func generatePreviews(for filters: [FilterModel], with originalImage: UIImage, completion: @escaping ([UIImage?]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let resized = originalImage.resize(to: CGSize(width: 200, height: 200))!
            var previews: [UIImage?] = [resized]

            for filter in filters.dropFirst() {
                let preview = self.filterService.applyFilter(to: resized, filter: filter, intensity: filter.defaultValue)
                previews.append(preview)
            }

            DispatchQueue.main.async {
                completion(previews)
            }
        }
    }
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = self.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}



