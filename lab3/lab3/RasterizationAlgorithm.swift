//
//  RasterizationAlgorithm.swift
//  lab3
//
//  Created by Yaraslau Merynau on 21.11.25.
//

import UIKit

// MARK: - Rasterization Algorithms

enum Algorithm: String, CaseIterable {
    case stepByStep = "Пошаговый"
    case dda = "ЦДА"
    case bresenhamLine = "Брезенхем (отрезок)"
    case bresenhamCircle = "Брезенхем (окружность)"
}

struct Point {
    let x: Int
    let y: Int
}

struct AlgorithmResult {
    let pixels: [Point]
    let executionTime: TimeInterval
}

class RasterizationAlgorithms {
    
    // MARK: - Пошаговый алгоритм
    static func stepByStep(x1: Int, y1: Int, x2: Int, y2: Int) -> AlgorithmResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        var pixels: [Point] = []
        
        let dx = x2 - x1
        let dy = y2 - y1
        
        guard dx != 0 else {
            // Вертикальная линия
            let minY = min(y1, y2)
            let maxY = max(y1, y2)
            for y in minY...maxY {
                pixels.append(Point(x: x1, y: y))
            }
            let time = CFAbsoluteTimeGetCurrent() - startTime
            return AlgorithmResult(pixels: pixels, executionTime: time)
        }
        
        let k = Double(dy) / Double(dx)
        let b = Double(y1) - k * Double(x1)
        
        if abs(dx) > abs(dy) {
            let startX = min(x1, x2)
            let endX = max(x1, x2)
            for x in startX...endX {
                let y = Int(round(k * Double(x) + b))
                pixels.append(Point(x: x, y: y))
            }
        } else {
            let startY = min(y1, y2)
            let endY = max(y1, y2)
            for y in startY...endY {
                let x = Int(round((Double(y) - b) / k))
                pixels.append(Point(x: x, y: y))
            }
        }
        
        let time = CFAbsoluteTimeGetCurrent() - startTime
        return AlgorithmResult(pixels: pixels, executionTime: time)
    }
    
    // MARK: - Алгоритм ЦДА (симметричный)
    static func dda(x1: Int, y1: Int, x2: Int, y2: Int) -> AlgorithmResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        var pixels: [Point] = []
        
        let dx = x2 - x1
        let dy = y2 - y1
        
        let length = max(abs(dx), abs(dy))
        guard length > 0 else {
            pixels.append(Point(x: x1, y: y1))
            let time = CFAbsoluteTimeGetCurrent() - startTime
            return AlgorithmResult(pixels: pixels, executionTime: time)
        }
        
        let xIncrement = Double(dx) / Double(length)
        let yIncrement = Double(dy) / Double(length)
        
        var x = Double(x1)
        var y = Double(y1)
        
        for _ in 0...length {
            pixels.append(Point(x: Int(round(x)), y: Int(round(y))))
            x += xIncrement
            y += yIncrement
        }
        
        let time = CFAbsoluteTimeGetCurrent() - startTime
        return AlgorithmResult(pixels: pixels, executionTime: time)
    }
    
    // MARK: - Целочисленный алгоритм Брезенхема (отрезок)
    static func bresenhamLine(x1: Int, y1: Int, x2: Int, y2: Int) -> AlgorithmResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        var pixels: [Point] = []
        
        var x = x1
        var y = y1
        
        let dx = abs(x2 - x1)
        let dy = abs(y2 - y1)
        
        let sx = x1 < x2 ? 1 : -1
        let sy = y1 < y2 ? 1 : -1
        
        var err = dx - dy
        
        while true {
            pixels.append(Point(x: x, y: y))
            
            if x == x2 && y == y2 { break }
            
            let e2 = 2 * err
            
            if e2 > -dy {
                err -= dy
                x += sx
            }
            
            if e2 < dx {
                err += dx
                y += sy
            }
        }
        
        let time = CFAbsoluteTimeGetCurrent() - startTime
        return AlgorithmResult(pixels: pixels, executionTime: time)
    }
    
    // MARK: - Целочисленный алгоритм Брезенхема (окружность)
    static func bresenhamCircle(centerX: Int, centerY: Int, radius: Int) -> AlgorithmResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        var pixels: [Point] = []
        
        var x = 0
        var y = radius
        var e = 3 - 2 * radius
        
        func addCirclePoints() {
            // Все 8 симметричных точек
            pixels.append(Point(x: centerX + x, y: centerY + y))
            pixels.append(Point(x: centerX + x, y: centerY - y))
            pixels.append(Point(x: centerX - x, y: centerY + y))
            pixels.append(Point(x: centerX - x, y: centerY - y))
            pixels.append(Point(x: centerX + y, y: centerY + x))
            pixels.append(Point(x: centerX + y, y: centerY - x))
            pixels.append(Point(x: centerX - y, y: centerY + x))
            pixels.append(Point(x: centerX - y, y: centerY - x))
        }
        
        addCirclePoints()
        
        while x < y {
            if e >= 0 {
                e = e + 4 * (x - y) + 10
                x += 1
                y -= 1
            } else {
                e = e + 4 * x + 6
                x += 1
            }
            addCirclePoints()
        }
        
        let time = CFAbsoluteTimeGetCurrent() - startTime
        return AlgorithmResult(pixels: pixels, executionTime: time)
    }
}
