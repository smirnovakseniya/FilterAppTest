import UIKit

final class SuccessAnimationView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.layer.cornerRadius = 20
        view.alpha = 0
        return view
    }()
    
    private let vStack = ReusableStackView(spacing: 12, axis: .vertical)
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "success_saved_message".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(vStack)
        
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(160)
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        
        vStack.addArrangedSubviews([
            checkmarkImageView,
            titleLabel
        ])
    }
    
    func show(on parentView: UIView, completion: (() -> Void)? = nil) {
        parentView.addSubview(self)
        
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.containerView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.checkmarkImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.checkmarkImageView.transform = .identity
            }
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.3) {
            self.titleLabel.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hide(completion: completion)
        }
    }
    
    private func hide(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 0
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
}

