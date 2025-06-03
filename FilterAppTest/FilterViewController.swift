import UIKit
import Combine
import SnapKit

final class FilterViewController: UIViewController {
    
    private let viewModel = FilterViewModel()
    
    private let vStack = ReusableStackView(axis: .vertical)
    private let filterImageContainer = UIView()
    private let filterImageView = FilterImageView()
    private let sliderContainerView = UIView()
    private let slider = SliderView()
    private let menuView = FilterMenuView()
    private let imagePicker = UIImagePickerController()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
        setupDelegates()
        
        handleActions()
    }
}

// MARK: - Setup

private extension FilterViewController {
    
    func setupUI() {
        view.backgroundColor = .appBlackColor
        
        view.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        setupFilterImageView()
        setupSlider()
        
        vStack.addArrangedSubviews([
            filterImageContainer,
            sliderContainerView,
            menuView
        ])
    }
    
    func setupFilterImageView() {
        filterImageContainer.clipsToBounds = true
        filterImageView.clipsToBounds = true

        filterImageContainer.addSubview(filterImageView)
        filterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(30)
        }
    }
    
    func setupSlider() {
        sliderContainerView.addSubview(slider)
        slider.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(50)
            make.verticalEdges.equalToSuperview().inset(16)
        }
        
        slider.onSliderValueChanged = { [weak self] value in
            self?.viewModel.applyFilter(intensity: value)
        }
    }
    
    func setupDelegates() {
        menuView.configureCollection(delegate: self,dataSource: self)
        imagePicker.delegate = self
    }
    
    //MARK: Binding
    
    func setupBindings() {
        
        viewModel.$filteredImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.filterImageView.setImage(image)
            }
            .store(in: &cancellables)
        
        viewModel.$originalImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self else { return }
                if image != nil {
                    showMenu()
                    filterImageView.updateEmptyState(isImageExist: true)
                    menuView.updateMenuState(isImageExist: true)
                } else {
                    hideMenu()
                    filterImageView.updateEmptyState(isImageExist: false)
                    menuView.updateMenuState(isImageExist: false)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$selectedFilterIndexPath
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] indexPath in
                self?.menuView.selectItem(at: indexPath, animated: true)
                self?.menuView.reloadCollection()
            }
            .store(in: &cancellables)
        
        viewModel.$selectedFilter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filter in
                guard let self = self, let filter = filter else {
                    self?.slider.setVisibility(false)
                    return
                }
                
                if filter.name == .original {
                    self.slider.setVisibility(false)
                } else {
                    self.slider.configure(
                        minValue: filter.minValue,
                        maxValue: filter.maxValue,
                        defaultValue: filter.defaultValue
                    )
                    self.slider.setVisibility(true)
                }
            }
            .store(in: &cancellables)
        
        viewModel.allPreviewsReadyPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] allReady in
                if allReady {
                    self?.menuView.reloadCollection()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Actions

private extension FilterViewController {
    
    func saveImage() {
        viewModel.checkPhotoLibraryPermission { [weak self] hasPermission in
            guard let self = self else { return }
            
            if hasPermission {
                self.saveImageToGallery()
            } else {
                self.showPermissionAlert()
            }
        }
    }
    
    func saveImageToGallery() {
        let scale = filterImageView.imageView.transform.a
        let rotation = atan2(filterImageView.imageView.transform.b, filterImageView.imageView.transform.a)
        
        if let transformedImage = viewModel.getTransformedImage(scale: scale, rotation: rotation) {
            viewModel.saveTransformedImage(transformedImage) { [weak self] success in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if success {
                        self.showSuccessAnimation { [weak self] in
                            self?.handleOkAction()
                        }
                    } else {
                        let title = "error_title".localized
                        let message = "error_saved_message".localized
                        
                        let alert = UIAlertController(
                            title: title,
                            message: message,
                            preferredStyle: .alert
                        )
                        
                        let okAction = UIAlertAction(
                            title: "ok_button".localized,
                            style: .default
                        )
                        alert.addAction(okAction)
                        
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    func showPermissionAlert() {
        let alert = UIAlertController(
            title: "permission_denied_title".localized,
            message: "permission_denied_message".localized,
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(
            title: "settings_button".localized,
            style: .default
        ) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        
        let cancelAction = UIAlertAction(
            title: "cancel_button".localized,
            style: .cancel
        )
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func handleOkAction() {
        viewModel.resetImage()
        filterImageView.resetTransform()
        filterImageView.updateEmptyState(isImageExist: false)
        menuView.updateMenuState(isImageExist: false)
        hideMenu()
        
        viewModel.selectedFilter = viewModel.filters.first(where: { $0.name == .original })
        viewModel.selectedFilterIndexPath = IndexPath(item: 0, section: 0)
        slider.alpha = 0
    }
    
    func handleActions() {
        menuView.onOpenGalleryTapped = { [weak self] in
            guard let self else { return }
            
            openGallery()
        }
        
        filterImageView.onEmptyImageTapped = { [weak self] in
            guard let self else { return }
            
            openGallery()
        }
        
        menuView.onFilterTapped = { [weak self] isCollectionVisible in
            guard let self else { return }
            
            updateView(isCollectionVisible: isCollectionVisible)
        }
        
        menuView.onSaveImageTapped = { [weak self] in
            guard let self else { return }
            
            saveImage()
        }
    }
    
    func openGallery() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    func showMenu() {
        menuView.toggleCollectionVisibility(visible: true)
        let isVisible = viewModel.selectedFilter?.name != .original
        updateSlider(isVisible: isVisible)
    }

    func hideMenu() {
        menuView.toggleCollectionVisibility(visible: false)
        updateSlider(isVisible: false)
    }
    
    func updateView(isCollectionVisible: Bool) {
        menuView.toggleCollectionVisibility(visible: isCollectionVisible) 
        updateSlider(isVisible: isCollectionVisible)
    }
    
    func updateSlider(isVisible: Bool) {
        let isOriginalFilter = viewModel.selectedFilter?.name != .original
        slider.setVisibility(isOriginalFilter && isVisible)
    }
    
    func showSuccessAnimation(completion: (() -> Void)? = nil) {
        let successView = SuccessAnimationView()
        successView.show(on: view, completion: completion)
    }
}

// MARK: - CollectionView

extension FilterViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FilterCollectionViewCell.identifier,
            for: indexPath
        ) as? FilterCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let filter = viewModel.filters[indexPath.row]
        let isSelected = (indexPath == viewModel.selectedFilterIndexPath)
        
        cell.configure(with: filter, image: filter.previewImage, isSelected: isSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = viewModel.filters[indexPath.row]
        viewModel.selectedFilter = filter
        viewModel.selectedFilterIndexPath = indexPath
        viewModel.applyFilter(intensity: filter.defaultValue)
    }
}

// MARK: - ImagePickerController

extension FilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.loadImage(image)
            menuView.reloadCollection()
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
