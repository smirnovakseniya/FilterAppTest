import UIKit

final class SliderView: UISlider {
    
    private let sliderContainerView = UIView()
    var onSliderValueChanged: ((Float) -> Void)?
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        minimumTrackTintColor = .systemBlue
        maximumTrackTintColor = .gray
        thumbTintColor = .white
        alpha = 0
        
        addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    func configure(minValue: Float, maxValue: Float, defaultValue: Float) {
        minimumValue = minValue
        maximumValue = maxValue
        value = defaultValue
    }
    
    func setVisibility(_ isVisible: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.alpha = isVisible ? 1 : 0
        }
    }
    
    @objc private func sliderValueChanged() {
        onSliderValueChanged?(value)
    }
}

