import UIKit

protocol PreviewGeneratorProtocol {
    func generatePreviews(for filters: [FilterModel], with originalImage: UIImage, completion: @escaping ([UIImage?]) -> Void)
}
