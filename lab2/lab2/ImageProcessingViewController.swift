import UIKit

// MARK: - Main View Controller
class ImageProcessingViewController: UIViewController {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let originalImageView = UIImageView()
    private let processedImageView = UIImageView()
    private let selectImageButton = UIButton(type: .system)
    private let filterControl = UISegmentedControl(items: ["Гаусс", "Бернсен", "Ниблацк"])
    private let processButton = UIButton(type: .system)
    private let parameterSlider = UISlider()
    private let parameterLabel = UILabel()
    
    private var originalImage: UIImage?
    private var processedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Обработка изображений"
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        selectImageButton.setTitle("Выбрать изображение", for: .normal)
        selectImageButton.addTarget(self, action: #selector(selectImageTapped), for: .touchUpInside)
        contentView.addSubview(selectImageButton)
        selectImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        filterControl.selectedSegmentIndex = 0
        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        contentView.addSubview(filterControl)
        filterControl.translatesAutoresizingMaskIntoConstraints = false
        
        parameterLabel.text = "Параметр b: 2"
        parameterLabel.textAlignment = .center
        contentView.addSubview(parameterLabel)
        parameterLabel.translatesAutoresizingMaskIntoConstraints = false

        parameterSlider.minimumValue = 1
        parameterSlider.maximumValue = 4
        parameterSlider.value = 2
        parameterSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        contentView.addSubview(parameterSlider)
        parameterSlider.translatesAutoresizingMaskIntoConstraints = false
        
        processButton.setTitle("Обработать", for: .normal)
        processButton.addTarget(self, action: #selector(processImage), for: .touchUpInside)
        contentView.addSubview(processButton)
        processButton.translatesAutoresizingMaskIntoConstraints = false

        originalImageView.contentMode = .scaleAspectFit
        originalImageView.backgroundColor = .systemGray6
        originalImageView.layer.borderWidth = 1
        originalImageView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.addSubview(originalImageView)
        originalImageView.translatesAutoresizingMaskIntoConstraints = false
        
        processedImageView.contentMode = .scaleAspectFit
        processedImageView.backgroundColor = .systemGray6
        processedImageView.layer.borderWidth = 1
        processedImageView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.addSubview(processedImageView)
        processedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            selectImageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            selectImageButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            filterControl.topAnchor.constraint(equalTo: selectImageButton.bottomAnchor, constant: 20),
            filterControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            filterControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            parameterLabel.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 20),
            parameterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            parameterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            parameterSlider.topAnchor.constraint(equalTo: parameterLabel.bottomAnchor, constant: 10),
            parameterSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            parameterSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            processButton.topAnchor.constraint(equalTo: parameterSlider.bottomAnchor, constant: 20),
            processButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            originalImageView.topAnchor.constraint(equalTo: processButton.bottomAnchor, constant: 20),
            originalImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            originalImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            originalImageView.heightAnchor.constraint(equalToConstant: 250),
            
            processedImageView.topAnchor.constraint(equalTo: originalImageView.bottomAnchor, constant: 20),
            processedImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            processedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            processedImageView.heightAnchor.constraint(equalToConstant: 250),
            processedImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        updateParameterLabel()
    }
    
    @objc private func selectImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @objc private func filterChanged() {
        updateParameterLabel()
    }
    
    @objc private func sliderChanged() {
        updateParameterLabel()
    }
    
    private func updateParameterLabel() {
        let filterIndex = filterControl.selectedSegmentIndex
        let value = Int(parameterSlider.value)
        
        switch filterIndex {
        case 0: // Гаусс
            parameterLabel.text = "Параметр b: \(value)"
            parameterSlider.isEnabled = true
        case 1: // Бернсен
            parameterLabel.text = "Размер окна r: 15, Порог ε: 15"
            parameterSlider.isEnabled = false
        case 2: // Ниблацк
            parameterLabel.text = "Размер окна r: 15, k: -0.2"
            parameterSlider.isEnabled = false
        default:
            break
        }
    }
    
    @objc private func processImage() {
        guard let image = originalImage else {
            showAlert(message: "Сначала выберите изображение")
            return
        }
        
        let filterIndex = filterControl.selectedSegmentIndex
        let b = Int(parameterSlider.value)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let processor = ImageProcessor()
            var result: UIImage?
            
            switch filterIndex {
            case 0: // Гаусс
                result = processor.applyGaussianFilter(to: image, b: b)
            case 1: // Бернсен
                result = processor.applyBernsenThreshold(to: image, r: 15, epsilon: 15)
            case 2: // Ниблацк
                result = processor.applyNiblackThreshold(to: image, r: 15, k: -0.2)
            default:
                break
            }
            
            DispatchQueue.main.async {
                self?.processedImage = result
                self?.processedImageView.image = result
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ImageProcessingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
            originalImageView.image = image
            processedImageView.image = nil
        }
        dismiss(animated: true)
    }
}
