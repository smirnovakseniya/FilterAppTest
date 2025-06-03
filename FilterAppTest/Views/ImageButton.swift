import UIKit

final class ImageButton: UIButton {
    
    init(systemImageName: String) {
        super.init(frame: .zero)
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: systemImageName)
        config.imagePadding = 8
        config.baseForegroundColor = .appWhiteColor
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

