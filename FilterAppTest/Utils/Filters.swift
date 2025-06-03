import UIKit
import CoreImage

class CommonData {
    
    static let filters: [FilterModel] = [
        .init(name: .original,
              ciFilterName: "",
              inputKey: "",
              defaultValue: 0.0, minValue: 0.0, maxValue: 0.0),
        
            .init(name: .sepiaTone,
                  ciFilterName: "CISepiaTone",
                  inputKey: kCIInputIntensityKey,
                  defaultValue: 0.5, minValue: 0.0, maxValue: 1.0),
        
            .init(name: .vignette,
                  ciFilterName: "CIVignette",
                  inputKey: kCIInputIntensityKey,
                  defaultValue: 0.5, minValue: 0.0, maxValue: 1.0),
        
            .init(name: .contrast,
                  ciFilterName: "CIColorControls",
                  inputKey: kCIInputContrastKey,
                  defaultValue: 0.5, minValue: 0.0, maxValue: 1.0),
        
            .init(name: .gamma,
                  ciFilterName: "CIGammaAdjust",
                  inputKey: "inputPower",
                  defaultValue: 0.5, minValue: 0.0, maxValue: 1.0),
        
            .init(name: .sharpen,
                  ciFilterName: "CISharpenLuminance",
                  inputKey: kCIInputSharpnessKey,
                  defaultValue: 0.5, minValue: 0.0, maxValue: 1.0),
        
            .init(name: .saturation,
                  ciFilterName: "CIColorControls",
                  inputKey: kCIInputSaturationKey,
                  defaultValue: 0.5, minValue: 0.0, maxValue: 1.0),
    ]
}
