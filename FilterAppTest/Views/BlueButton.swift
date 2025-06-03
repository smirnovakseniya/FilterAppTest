import UIKit

final class BlueButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.cornerStyle = .capsule
        
        self.configuration = config
        self.isHidden = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
