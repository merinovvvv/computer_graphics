//
//  ColorModelsViewController.swift
//  lab1
//
//  Created by Yaraslau Merynau on 16.10.25.
//

import UIKit

// MARK: - Main View Controller
class ColorModelsViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let colorPreview = UIView()
    private let rgbView: ColorModelView
    private let cmykView: ColorModelView
    private let hsvView: ColorModelView
    private let colorPickerButton = UIButton(type: .system)
    
    private var isUpdating = false
    
    init() {
        rgbView = ColorModelView(title: "RGB", components: [
            ("R", 255), ("G", 255), ("B", 255)
        ])
        cmykView = ColorModelView(title: "CMYK", components: [
            ("C", 100), ("M", 100), ("Y", 100), ("K", 100)
        ])
        hsvView = ColorModelView(title: "HSV", components: [
            ("H", 360), ("S", 100), ("V", 100)
        ])
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCallbacks()
        
        rgbView.updateValues([128, 64, 192])
        updateFromRGB([128, 64, 192])
    }
    
    private func setupUI() {
        title = "Цветовые модели"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        colorPreview.layer.cornerRadius = 12
        colorPreview.layer.borderWidth = 2
        colorPreview.layer.borderColor = UIColor.systemGray3.cgColor
        
        colorPickerButton.setTitle("Выбрать из палитры", for: .normal)
        colorPickerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        colorPickerButton.backgroundColor = .systemBlue
        colorPickerButton.setTitleColor(.white, for: .normal)
        colorPickerButton.layer.cornerRadius = 10
        colorPickerButton.addTarget(self, action: #selector(showColorPicker), for: .touchUpInside)
        
        contentView.addSubview(colorPreview)
        contentView.addSubview(colorPickerButton)
        contentView.addSubview(rgbView)
        contentView.addSubview(cmykView)
        contentView.addSubview(hsvView)
        
        colorPreview.translatesAutoresizingMaskIntoConstraints = false
        colorPickerButton.translatesAutoresizingMaskIntoConstraints = false
        rgbView.translatesAutoresizingMaskIntoConstraints = false
        cmykView.translatesAutoresizingMaskIntoConstraints = false
        hsvView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 16
        
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
            
            colorPreview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            colorPreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            colorPreview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            colorPreview.heightAnchor.constraint(equalToConstant: 120),
            
            colorPickerButton.topAnchor.constraint(equalTo: colorPreview.bottomAnchor, constant: 12),
            colorPickerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            colorPickerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            colorPickerButton.heightAnchor.constraint(equalToConstant: 50),
            
            rgbView.topAnchor.constraint(equalTo: colorPickerButton.bottomAnchor, constant: 20),
            rgbView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            rgbView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            rgbView.heightAnchor.constraint(equalToConstant: 180),
            
            cmykView.topAnchor.constraint(equalTo: rgbView.bottomAnchor, constant: 16),
            cmykView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            cmykView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            cmykView.heightAnchor.constraint(equalToConstant: 220),
            
            hsvView.topAnchor.constraint(equalTo: cmykView.bottomAnchor, constant: 16),
            hsvView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            hsvView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            hsvView.heightAnchor.constraint(equalToConstant: 180),
            hsvView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }
    
    private func setupCallbacks() {
        rgbView.onValueChanged = { [weak self] values in
            self?.updateFromRGB(values)
        }
        
        cmykView.onValueChanged = { [weak self] values in
            self?.updateFromCMYK(values)
        }
        
        hsvView.onValueChanged = { [weak self] values in
            self?.updateFromHSV(values)
        }
    }
    
    @objc private func showColorPicker() {
        if #available(iOS 14.0, *) {
            let picker = UIColorPickerViewController()
            picker.delegate = self
            picker.selectedColor = colorPreview.backgroundColor ?? .white
            present(picker, animated: true)
        }
    }
    
    private func updateFromRGB(_ values: [CGFloat]) {
        guard !isUpdating else { return }
        isUpdating = true
        
        let r = values[0] / 255
        let g = values[1] / 255
        let b = values[2] / 255
        
        colorPreview.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1)
        
        let cmyk = ColorConverter.rgbToCMYK(r: r, g: g, b: b)
        cmykView.updateValues([cmyk.c * 100, cmyk.m * 100, cmyk.y * 100, cmyk.k * 100])
        
        let hsv = ColorConverter.rgbToHSV(r: r, g: g, b: b)
        hsvView.updateValues([hsv.h, hsv.s * 100, hsv.v * 100])
        
        isUpdating = false
    }
    
    private func updateFromCMYK(_ values: [CGFloat]) {
        guard !isUpdating else { return }
        isUpdating = true
        
        let c = values[0] / 100
        let m = values[1] / 100
        let y = values[2] / 100
        let k = values[3] / 100
        
        let rgb = ColorConverter.cmykToRGB(c: c, m: m, y: y, k: k)
        rgbView.updateValues([rgb.r * 255, rgb.g * 255, rgb.b * 255])
        
        colorPreview.backgroundColor = UIColor(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: 1)
        
        let hsv = ColorConverter.rgbToHSV(r: rgb.r, g: rgb.g, b: rgb.b)
        hsvView.updateValues([hsv.h, hsv.s * 100, hsv.v * 100])
        
        isUpdating = false
    }
    
    private func updateFromHSV(_ values: [CGFloat]) {
        guard !isUpdating else { return }
        isUpdating = true
        
        let h = values[0]
        let s = values[1] / 100
        let v = values[2] / 100
        
        let rgb = ColorConverter.hsvToRGB(h: h, s: s, v: v)
        rgbView.updateValues([rgb.r * 255, rgb.g * 255, rgb.b * 255])
        
        colorPreview.backgroundColor = UIColor(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: 1)
        
        let cmyk = ColorConverter.rgbToCMYK(r: rgb.r, g: rgb.g, b: rgb.b)
        cmykView.updateValues([cmyk.c * 100, cmyk.m * 100, cmyk.y * 100, cmyk.k * 100])
        
        isUpdating = false
    }
}

@available(iOS 14.0, *)
extension ColorModelsViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        updateFromRGB([r * 255, g * 255, b * 255])
    }
}
