//
//  RasterCanvasView.swift
//  lab3
//
//  Created by Yaraslau Merynau on 21.11.25.
//

import UIKit

// MARK: - Canvas View

class RasterCanvasView: UIView {
    
    var pixels: [Point] = []
    var gridScale: CGFloat = 20.0
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        addGestureRecognizer(pinchGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        offsetX += translation.x
        offsetY += translation.y
        gesture.setTranslation(.zero, in: self)
        setNeedsDisplay()
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            let newScale = gridScale * gesture.scale
            if newScale >= 5 && newScale <= 50 {
                gridScale = newScale
                gesture.scale = 1.0
                setNeedsDisplay()
            }
        }
    }
    
    func updatePixels(_ newPixels: [Point]) {
        pixels = newPixels
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let centerX = bounds.width / 2 + offsetX
        let centerY = bounds.height / 2 + offsetY
        
        // Рисуем сетку
        context.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(0.5)
        
        let gridSpacing = gridScale
        
        // Вертикальные линии
        var x = centerX.truncatingRemainder(dividingBy: gridSpacing)
        while x < bounds.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: bounds.height))
            x += gridSpacing
        }
        
        // Горизонтальные линии
        var y = centerY.truncatingRemainder(dividingBy: gridSpacing)
        while y < bounds.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: bounds.width, y: y))
            y += gridSpacing
        }
        
        context.strokePath()
        
        // Рисуем оси координат
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2)
        
        // Ось Y
        context.move(to: CGPoint(x: centerX, y: 0))
        context.addLine(to: CGPoint(x: centerX, y: bounds.height))
        
        // Ось X
        context.move(to: CGPoint(x: 0, y: centerY))
        context.addLine(to: CGPoint(x: bounds.width, y: centerY))
        
        context.strokePath()
        
        // Подписи осей
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        // Подписи на оси X
        var gridX = Int(-centerX / gridSpacing) - 1
        var screenX = centerX + CGFloat(gridX) * gridSpacing
        
        while screenX < bounds.width {
            if gridX != 0 && screenX > 20 && screenX < bounds.width - 20 {
                let label = "\(gridX)" as NSString
                let size = label.size(withAttributes: attributes)
                label.draw(at: CGPoint(x: screenX - size.width/2, y: centerY + 5), withAttributes: attributes)
            }
            gridX += 1
            screenX += gridSpacing
        }
        
        // Подписи на оси Y (инвертированные для компьютерной графики)
        var gridY = Int(-centerY / gridSpacing) - 1
        var screenY = centerY + CGFloat(gridY) * gridSpacing
        
        while screenY < bounds.height {
            if gridY != 0 && screenY > 20 && screenY < bounds.height - 20 {
                let label = "\(-gridY)" as NSString
                let size = label.size(withAttributes: attributes)
                label.draw(at: CGPoint(x: centerX + 5, y: screenY - size.height/2), withAttributes: attributes)
            }
            gridY += 1
            screenY += gridSpacing
        }
        
        // Подписи осей
        "X".draw(at: CGPoint(x: bounds.width - 20, y: centerY + 5), withAttributes: attributes)
        "Y".draw(at: CGPoint(x: centerX + 5, y: 10), withAttributes: attributes)
        
        // Рисуем пиксели
        context.setFillColor(UIColor.systemBlue.cgColor)
        
        for pixel in pixels {
            let screenX = centerX + CGFloat(pixel.x) * gridSpacing
            let screenY = centerY - CGFloat(pixel.y) * gridSpacing
            
            let pixelRect = CGRect(
                x: screenX - gridSpacing/2,
                y: screenY - gridSpacing/2,
                width: gridSpacing,
                height: gridSpacing
            )
            context.fill(pixelRect)
        }
    }
}
