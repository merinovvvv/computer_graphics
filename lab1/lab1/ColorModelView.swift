//
//  ColorModelView.swift
//  lab1
//
//  Created by Yaraslau Merynau on 16.10.25.
//

import UIKit

// MARK: - Color Model View
class ColorModelView: UIView {
    
    //MARK: - Properties
    
    var onValueChanged: (([CGFloat]) -> Void)?
    private var isUpdating = false
    
    //MARK: - UI Properties
    
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    
    private var sliders: [UISlider] = []
    private var textFields: [UITextField] = []
    private var labels: [UILabel] = []
    
    //MARK: - Init
    
    init(title: String, components: [(name: String, max: CGFloat)]) {
        super.init(frame: .zero)
        setupUI(title: title, components: components)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String, components: [(name: String, max: CGFloat)]) {
        self.backgroundColor = UIColor.systemBackground
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray4.cgColor
        
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        
        addSubview(titleLabel)
        addSubview(stackView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        
        for (name, maxValue) in components {
            let componentView = createComponentView(name: name, maxValue: maxValue)
            stackView.addArrangedSubview(componentView)
        }
    }
    
    private func createComponentView(name: String, maxValue: CGFloat) -> UIView {
        let container = UIView()
        
        let label = UILabel()
        label.text = name
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = Float(maxValue)
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.textAlignment = .center
        textField.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        labels.append(label)
        sliders.append(slider)
        textFields.append(textField)
        
        container.addSubview(label)
        container.addSubview(slider)
        container.addSubview(textField)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 30),
            
            slider.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            slider.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            slider.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -8),
            
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textField.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        return container
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        guard !isUpdating else { return }
        if let index = sliders.firstIndex(of: sender) {
            textFields[index].text = String(format: "%.2f", sender.value)
        }
        notifyValueChanged()
    }
    
    @objc private func textFieldChanged(_ sender: UITextField) {
        guard !isUpdating else { return }
        if let index = textFields.firstIndex(of: sender),
           let value = Float(sender.text ?? "") {
            sliders[index].value = min(max(value, sliders[index].minimumValue), sliders[index].maximumValue)
        }
        notifyValueChanged()
    }
    
    private func notifyValueChanged() {
        let values = sliders.map { CGFloat($0.value) }
        onValueChanged?(values)
    }
    
    func updateValues(_ values: [CGFloat]) {
        isUpdating = true
        for (index, value) in values.enumerated() {
            sliders[index].value = Float(value)
            textFields[index].text = String(format: "%.2f", value)
        }
        isUpdating = false
    }
    
    func getValues() -> [CGFloat] {
        return sliders.map { CGFloat($0.value) }
    }
}

extension ColorModelView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
