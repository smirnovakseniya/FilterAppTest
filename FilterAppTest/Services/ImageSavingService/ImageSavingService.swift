import UIKit

final class ImageSavingService: ImageSavingServiceProtocol {
    
    func save(_ image: UIImage?, completion: @escaping (Bool) -> Void) {
        guard let image = image else {
            completion(false)
            return
        }
        
        DispatchQueue.main.async {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            completion(true)
        }
    }
}
