import UIKit

final class FilterMenuView: UIView {
    
    private var isCollectionVisible: Bool = false
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 82, height: 140)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .appDarkGrayColor
        collectionView.layer.cornerRadius = 16
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let vStack = ReusableStackView(axis: .vertical)
    
    private lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = .appGrayColor
        view.alpha = 0
        view.isHidden = true
        return view
    }()
    
    private let buttonsView = UIView()
    private let buttonsContainerView = UIView()
    
    private let saveButton = BlueButton(title: "save_button".localized)
    private let chooseButton = ImageButton(systemImageName: "plus.app")
    private let filterButton = TextButton(title: "filters_button".localized.uppercased())
    
    var onOpenGalleryTapped: (() -> ())?
    var onFilterTapped: ((Bool) -> ())?
    var onSaveImageTapped: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

//MARK: UI

private extension FilterMenuView {
    
    func setupUI() {
        
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        self.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(140)
        }
        
        line.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        buttonsView.addSubview(chooseButton)
        chooseButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
        }
        
        buttonsView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.trailing.verticalEdges.equalToSuperview()
            make.height.equalTo(40)
        }
        
        buttonsView.addSubview(filterButton)
        filterButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        buttonsContainerView.backgroundColor = .appDarkGrayColor
        buttonsContainerView.addSubview(buttonsView)
        buttonsView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(28)
        }
        
        vStack.addArrangedSubviews([
            collectionView,
            line,
            buttonsContainerView
        ])
        
        toggleCollectionVisibility(visible: isCollectionVisible, animated: false)
        
        chooseButton.addTarget(self, action: #selector(tapOpenGalleryButton), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(tapFilterButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(tapSaveImageButton), for: .touchUpInside)
    }
    
}

//MARK: Actions

extension FilterMenuView {
    
    func configureCollection(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
    }
    
    func reloadCollection() {
        collectionView.reloadData()
    }
    
    func updateMenuState(isImageExist: Bool) {
        toggleCollectionVisibility(visible: isImageExist)
        saveButton.isHidden = !isImageExist
        filterButton.isUserInteractionEnabled = isImageExist
    }
    
    func toggleCollectionVisibility(visible: Bool, animated: Bool = true) {
        isCollectionVisible = visible
        
        let transformIdentity = CGAffineTransform.identity
        let transformHidden = CGAffineTransform(translationX: 0, y: 150)
        
        if visible {
            collectionView.isHidden = false
            line.isHidden = false
            collectionView.transform = transformHidden
            line.transform = transformHidden
        }
        
        let duration = animated ? 0.5 : 0
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut]) { [weak self] in
            guard let self = self else { return }
            self.collectionView.alpha = visible ? 1 : 0
            self.line.alpha = visible ? 1 : 0
            self.collectionView.transform = visible ? transformIdentity : transformHidden
            self.line.transform = visible ? transformIdentity : transformHidden
            
        }
    }
    
    func selectItem(at indexPath: IndexPath, animated: Bool) {
        collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
    }
    
    func deselectItem(at indexPath: IndexPath, animated: Bool) {
        collectionView.deselectItem(at: indexPath, animated: animated)
    }
}

@objc private extension FilterMenuView {
    
    func tapOpenGalleryButton() {
        onOpenGalleryTapped?()
    }
    
    func tapSaveImageButton() {
        onSaveImageTapped?()
    }
    
    func tapFilterButton() {
        isCollectionVisible.toggle()
        onFilterTapped?(isCollectionVisible)
    }
}
