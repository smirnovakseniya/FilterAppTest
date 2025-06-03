import Foundation

final class ServiceFactory {
    static let shared = ServiceFactory()
    
    private init() {}
    
    func makeFilterService() -> ImageFilteringServiceProtocol {
        return ImageFilteringService()
    }
    
    func makePreviewGeneratorService() -> PreviewGeneratorProtocol {
        return PreviewGenerator(filterService: makeFilterService())
    }
    
    func makeImageTransformingService() -> ImageTransformingServiceProtocol {
        return ImageTransformingService()
    }
    
    func makeImageSavingService() -> ImageSavingServiceProtocol {
        return ImageSavingService()
    }
    
    func makePermissionService() -> PermissionServiceProtocol {
        return PermissionService()
    }
}
