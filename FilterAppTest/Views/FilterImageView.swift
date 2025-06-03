import UIKit

final class FilterImageView: UIView {
    
    private enum Constants {
        static let minScale: CGFloat = 0.5
        static let maxScale: CGFloat = 3.0
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let emptyImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "photo.badge.plus")
        iv.tintColor = .appLightGrayColor
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private var pinchGestureRecognizer: UIPinchGestureRecognizer!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var rotationGestureRecognizer: UIRotationGestureRecognizer!
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    var onEmptyImageTapped: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupGestures()
        
        layer.cornerRadius = 20
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
        setupGestures()
        
        layer.cornerRadius = 20
        layer.masksToBounds = true
    }
}

// MARK: Actions

extension FilterImageView {
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
        updateEmptyState(isImageExist: image != nil)
    }
    
    func resetTransform() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            imageView.transform = .identity
        }
    }
    
    func updateEmptyState(isImageExist: Bool) {
        emptyImageView.isHidden = isImageExist
    }
}

// MARK: UI

private extension FilterImageView {
    
    func setupUI() {
        addSubview(imageView)
        addSubview(emptyImageView)
        
        imageView.clipsToBounds = false
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(50)
        }
        
        updateEmptyState(isImageExist: false)
    }
}

// MARK: Gestures

private extension FilterImageView {
    
    func setupGestures() {
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(_:)))
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        imageView.addGestureRecognizer(pinchGestureRecognizer)
        imageView.addGestureRecognizer(panGestureRecognizer)
        imageView.addGestureRecognizer(rotationGestureRecognizer)
        
        emptyImageView.addGestureRecognizer(tapGestureRecognizer)
        
        pinchGestureRecognizer.delegate = self
        rotationGestureRecognizer.delegate = self
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.view != nil else { return }
        
        if gesture.state == .changed {
            let currentScale = imageView.transform.a
            let newScale = currentScale * gesture.scale
            
            if newScale >= Constants.minScale && newScale <= Constants.maxScale {
                imageView.transform = imageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            }
            gesture.scale = 1.0
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.view != nil else { return }
        
        let translation = gesture.translation(in: imageView.superview)
        if gesture.state == .changed {
            imageView.center = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
            gesture.setTranslation(.zero, in: imageView.superview)
        }
    }
    
    @objc private func handleRotate(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.view != nil else { return }
        
        if gesture.state == .changed {
            imageView.transform = imageView.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0.0
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        onEmptyImageTapped?()
    }
}

extension FilterImageView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer:
        UIGestureRecognizer
    ) -> Bool {
        if (gestureRecognizer == pinchGestureRecognizer && otherGestureRecognizer == rotationGestureRecognizer) ||
            (gestureRecognizer == rotationGestureRecognizer && otherGestureRecognizer == pinchGestureRecognizer) {
            return true
        }
        return false
    }
}
