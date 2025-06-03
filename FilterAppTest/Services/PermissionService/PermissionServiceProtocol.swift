import UIKit

protocol PermissionServiceProtocol {
    func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void)
}
