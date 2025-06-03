import UIKit

final class TextButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .appLightGrayColor 
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
