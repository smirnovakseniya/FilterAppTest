import UIKit

final class FilterCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "FilterCell"
    
    private let vStack = ReusableStackView(spacing: 8, axis: .vertical, alignment: .center)
    
    private let borderedView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .appWhiteColor
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        borderedView.layer.borderColor = UIColor.clear.cgColor
    }
}

// MARK: Configure

extension FilterCollectionViewCell {
    
    func configure(with filter: FilterModel, image: UIImage?, isSelected: Bool) {
        imageView.image = image
        titleLabel.text = filter.name.rawValue.localized
        borderedView.layer.borderColor = isSelected ? UIColor.white.cgColor : UIColor.clear.cgColor
    }
}

// MARK: UI

private extension FilterCollectionViewCell {

    func setup() {
        contentView.addSubview(vStack)
        
        vStack.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview()
        }
        
        borderedView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        
        vStack.addArrangedSubviews([
            borderedView,
            titleLabel
        ])
        
        borderedView.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(100)
        }
    }
}

