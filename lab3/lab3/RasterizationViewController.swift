//
//  RasterizationViewController.swift
//  lab3
//
//  Created by Yaraslau Merynau on 21.11.25.
//

import UIKit

class RasterizationViewController: UIViewController {
    
    private let canvasView = RasterCanvasView()
    private let controlsContainer = UIView()
    
    private let algorithmPicker = UIPickerView()
    private var selectedAlgorithm: Algorithm = .stepByStep
    
    private let x1TextField = UITextField()
    private let y1TextField = UITextField()
    private let x2TextField = UITextField()
    private let y2TextField = UITextField()
    private let radiusTextField = UITextField()
    
    private let drawButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)
    private let timeLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Растровые алгоритмы"
        view.backgroundColor = .systemBackground
        
        setupCanvas()
        setupControls()
        setupLayout()
    }
    
    private func setupCanvas() {
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
    }
    
    private func setupControls() {
        controlsContainer.backgroundColor = .systemGray6
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsContainer)
        
        // Picker
        algorithmPicker.delegate = self
        algorithmPicker.dataSource = self
        algorithmPicker.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(algorithmPicker)
        
        // Text fields
        setupTextField(x1TextField, placeholder: "X1", defaultValue: "0")
        setupTextField(y1TextField, placeholder: "Y1", defaultValue: "0")
        setupTextField(x2TextField, placeholder: "X2", defaultValue: "10")
        setupTextField(y2TextField, placeholder: "Y2", defaultValue: "5")
        setupTextField(radiusTextField, placeholder: "Радиус", defaultValue: "5")
        radiusTextField.isHidden = true
        
        let stackView = UIStackView(arrangedSubviews: [x1TextField, y1TextField, x2TextField, y2TextField, radiusTextField])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(stackView)
        
        // Buttons
        drawButton.setTitle("Нарисовать", for: .normal)
        drawButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        drawButton.backgroundColor = .systemBlue
        drawButton.setTitleColor(.white, for: .normal)
        drawButton.layer.cornerRadius = 8
        drawButton.addTarget(self, action: #selector(drawTapped), for: .touchUpInside)
        drawButton.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(drawButton)
        
        clearButton.setTitle("Очистить", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 16)
        clearButton.backgroundColor = .systemGray4
        clearButton.setTitleColor(.label, for: .normal)
        clearButton.layer.cornerRadius = 8
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(clearButton)
        
        // Time label
        timeLabel.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        timeLabel.textAlignment = .center
        timeLabel.numberOfLines = 0
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            algorithmPicker.topAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: 8),
            algorithmPicker.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 16),
            algorithmPicker.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -16),
            algorithmPicker.heightAnchor.constraint(equalToConstant: 100),
            
            stackView.topAnchor.constraint(equalTo: algorithmPicker.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 44),
            
            drawButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12),
            drawButton.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 16),
            drawButton.widthAnchor.constraint(equalTo: controlsContainer.widthAnchor, multiplier: 0.5, constant: -20),
            drawButton.heightAnchor.constraint(equalToConstant: 44),
            
            clearButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12),
            clearButton.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -16),
            clearButton.widthAnchor.constraint(equalTo: controlsContainer.widthAnchor, multiplier: 0.5, constant: -20),
            clearButton.heightAnchor.constraint(equalToConstant: 44),
            
            timeLabel.topAnchor.constraint(equalTo: drawButton.bottomAnchor, constant: 12),
            timeLabel.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -16),
            timeLabel.bottomAnchor.constraint(lessThanOrEqualTo: controlsContainer.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String, defaultValue: String) {
        textField.placeholder = placeholder
        textField.text = defaultValue
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numbersAndPunctuation
        textField.textAlignment = .center
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            controlsContainer.topAnchor.constraint(equalTo: canvasView.bottomAnchor),
            controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            controlsContainer.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    @objc private func drawTapped() {
        view.endEditing(true)
        
        let result: AlgorithmResult
        
        switch selectedAlgorithm {
        case .stepByStep, .dda, .bresenhamLine:
            guard let x1 = Int(x1TextField.text ?? ""),
                  let y1 = Int(y1TextField.text ?? ""),
                  let x2 = Int(x2TextField.text ?? ""),
                  let y2 = Int(y2TextField.text ?? "") else {
                showAlert("Ошибка", "Введите корректные координаты")
                return
            }
            
            switch selectedAlgorithm {
            case .stepByStep:
                result = RasterizationAlgorithms.stepByStep(x1: x1, y1: y1, x2: x2, y2: y2)
            case .dda:
                result = RasterizationAlgorithms.dda(x1: x1, y1: y1, x2: x2, y2: y2)
            case .bresenhamLine:
                result = RasterizationAlgorithms.bresenhamLine(x1: x1, y1: y1, x2: x2, y2: y2)
            default:
                return
            }
            
        case .bresenhamCircle:
            guard let x = Int(x1TextField.text ?? ""),
                  let y = Int(y1TextField.text ?? ""),
                  let radius = Int(radiusTextField.text ?? "") else {
                showAlert("Ошибка", "Введите корректные координаты центра и радиус")
                return
            }
            
            result = RasterizationAlgorithms.bresenhamCircle(centerX: x, centerY: y, radius: radius)
        }
        
        canvasView.updatePixels(result.pixels)
        
        let timeMs = result.executionTime * 1000
        let pixelCount = result.pixels.count
        timeLabel.text = String(format: "Время: %.4f мс\nПикселей: %d", timeMs, pixelCount)
    }
    
    @objc private func clearTapped() {
        canvasView.updatePixels([])
        timeLabel.text = ""
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Picker Delegate

extension RasterizationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Algorithm.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Algorithm.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedAlgorithm = Algorithm.allCases[row]
        
        let isCircle = selectedAlgorithm == .bresenhamCircle
        radiusTextField.isHidden = !isCircle
        x2TextField.isHidden = isCircle
        y2TextField.isHidden = isCircle
        
        if isCircle {
            x1TextField.placeholder = "Центр X"
            y1TextField.placeholder = "Центр Y"
        } else {
            x1TextField.placeholder = "X1"
            y1TextField.placeholder = "Y1"
        }
    }
}
