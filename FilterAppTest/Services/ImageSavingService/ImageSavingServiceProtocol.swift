import UIKit

protocol ImageSavingServiceProtocol {
    func save(_ image: UIImage?, completion: @escaping (Bool) -> Void)
}
