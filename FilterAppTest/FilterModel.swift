import UIKit

struct FilterModel {
    let name: FilterName
    let ciFilterName: String
    let inputKey: String
    let defaultValue: Float
    let minValue: Float
    let maxValue: Float

    var previewImage: UIImage?

    init(name: FilterName,
         ciFilterName: String,
         inputKey: String,
         defaultValue: Float,
         minValue: Float = 0,
         maxValue: Float = 1,
         previewImage: UIImage? = nil
    ) {

        self.name = name
        self.ciFilterName = ciFilterName
        self.inputKey = inputKey
        self.defaultValue = defaultValue
        self.minValue = minValue
        self.maxValue = maxValue
        self.previewImage = previewImage
    }
}
