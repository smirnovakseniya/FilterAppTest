import UIKit
import Combine

protocol FilterViewModelProtocol: ObservableObject {
    var filteredImage: UIImage? { get set }
    var selectedFilter: FilterModel? { get set }
    var selectedFilterIndexPath: IndexPath? { get set }
    var originalImage: UIImage? { get set }
    var filters: [FilterModel] { get set }
    var allPreviewsReadyPublisher: AnyPublisher<Bool, Never> { get }

    func loadImage(_ image: UIImage)
    func resetImage()
    func applyFilter(intensity: Float)
    func saveImage(completion: @escaping (Bool) -> Void)
}
