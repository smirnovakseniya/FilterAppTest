import UIKit

final class ReusableStackView: UIStackView {

    init(spacing: CGFloat = 0, axis: NSLayoutConstraint.Axis, alignment: Alignment = .fill) {
        super.init(frame: .zero)
        
        self.axis = axis
        self.spacing = spacing
        
        self.alignment = alignment
        self.distribution = .fill
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

