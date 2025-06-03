import UIKit
import CoreImage
import Combine

final class FilterViewModel: FilterViewModelProtocol {
    
    @Published var filteredImage: UIImage?
    @Published var selectedFilter: FilterModel?
    @Published var selectedFilterIndexPath: IndexPath?
    @Published var originalImage: UIImage? {
        didSet {
            filters.indices.forEach { filters[$0].previewImage = nil }
            
            filteredImage = originalImage
            selectedFilterIndexPath = IndexPath(item: 0, section: 0)
            selectedFilter = filters.first
            
            if originalImage != nil {
                generateFilterPreviews()
            }
        }
    }
    
    @Published var filters: [FilterModel] = CommonData.filters
    
    private var cancellables = Set<AnyCancellable>()
    private var filterTask: DispatchWorkItem?
    private var lastUpdate: Date = Date.distantPast
    
    var allPreviewsReadyPublisher: AnyPublisher<Bool, Never> {
        $filters
            .map { $0.allSatisfy { $0.previewImage != nil } }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private let serviceFactory = ServiceFactory.shared
    
    private let filterService: ImageFilteringServiceProtocol
    private let previewService: PreviewGeneratorProtocol
    private let transformService: ImageTransformingServiceProtocol
    private let saveService: ImageSavingServiceProtocol
    private let permissionService: PermissionServiceProtocol
    
    init() {
        self.filterService = serviceFactory.makeFilterService()
        self.previewService = serviceFactory.makePreviewGeneratorService()
        self.transformService = serviceFactory.makeImageTransformingService()
        self.saveService = serviceFactory.makeImageSavingService()
        self.permissionService = serviceFactory.makePermissionService()
    }
    
    func loadImage(_ image: UIImage) {
        originalImage = transformService.fixedOrientation(image: image)
    }
    
    func resetImage() {
        originalImage = nil
    }
    
    private func generateFilterPreviews() {
        guard let image = originalImage else {
            filters.indices.forEach { filters[$0].previewImage = nil }
            return
        }
        
        previewService.generatePreviews(for: filters, with: image) { previews in
            for i in self.filters.indices {
                self.filters[i].previewImage = i < previews.count ? previews[i] : nil
            }
        }
    }
    
    func applyFilter(intensity: Float) {
        guard let image = originalImage, let filter = selectedFilter else {
            filteredImage = originalImage
            return
        }
        
        if filter.name == .original {
            filteredImage = image
            return
        }
        
        let now = Date()
        let timeSinceLastUpdate = now.timeIntervalSince(lastUpdate)
        
        if timeSinceLastUpdate < 0.01 {
            filterTask?.cancel()
            
            let task = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if self.selectedFilter?.name == filter.name {
                        self.filteredImage = self.filterService.applyFilter(to: image, filter: filter, intensity: intensity)
                        self.lastUpdate = Date()
                    }
                }
            }
            
            filterTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: task)
        } else {
            filteredImage = filterService.applyFilter(to: image, filter: filter, intensity: intensity)
            lastUpdate = now
        }
    }
    
    func saveImage(completion: @escaping (Bool) -> Void) {
        saveService.save(filteredImage, completion: completion)
    }
    
    func getTransformedImage(scale: CGFloat, rotation: CGFloat) -> UIImage? {
        guard let image = filteredImage else { return nil }
        return transformService.renderTransformedImage(from: image, scale: scale, rotation: rotation)
    }
    
    func saveTransformedImage(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        saveService.save(image, completion: completion)
    }
    
    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        permissionService.requestPhotoLibraryAccess(completion: completion)
    }
}
