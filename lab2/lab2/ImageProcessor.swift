import UIKit

// MARK: - Image Processor
class ImageProcessor {
    
    // MARK: - Gaussian Filter
    func applyGaussianFilter(to image: UIImage, b: Int) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Create Gaussian kernel
        let kernel = createGaussianKernel(b: b)
        let W = calculateW(b: b)
        
        var outputData = pixelData
        
        for m in 1..<(height-1) {
            for n in 1..<(width-1) {
                var sumR: Double = 0
                var sumG: Double = 0
                var sumB: Double = 0
                
                for i in -1...1 {
                    for j in -1...1 {
                        let pixelIndex = ((m + i) * width + (n + j)) * bytesPerPixel
                        let weight = kernel[i + 1][j + 1]
                        
                        sumR += Double(pixelData[pixelIndex]) * weight
                        sumG += Double(pixelData[pixelIndex + 1]) * weight
                        sumB += Double(pixelData[pixelIndex + 2]) * weight
                    }
                }
                
                let outputIndex = (m * width + n) * bytesPerPixel
                outputData[outputIndex] = UInt8(min(max(sumR / W, 0), 255))
                outputData[outputIndex + 1] = UInt8(min(max(sumG / W, 0), 255))
                outputData[outputIndex + 2] = UInt8(min(max(sumB / W, 0), 255))
                outputData[outputIndex + 3] = pixelData[outputIndex + 3]
            }
        }
        
        return createImage(from: outputData, width: width, height: height)
    }
    
    private func createGaussianKernel(b: Int) -> [[Double]] {
        let bDouble = Double(b)
        return [
            [1.0, bDouble, 1.0],
            [bDouble, bDouble * bDouble, bDouble],
            [1.0, bDouble, 1.0]
        ]
    }
    
    private func calculateW(b: Int) -> Double {
        let bDouble = Double(b)
        return pow(2.0 + bDouble, 2.0)
    }
    
    // MARK: - Bernsen Threshold
    func applyBernsenThreshold(to image: UIImage, r: Int, epsilon: Int) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var outputData = pixelData
        
        for m in r..<(height - r) {
            for n in r..<(width - r) {
                var minVal: UInt8 = 255
                var maxVal: UInt8 = 0
                
                // Find min and max in window
                for i in -r...r {
                    for j in -r...r {
                        let pixelIndex = ((m + i) * width + (n + j)) * bytesPerPixel
                        let val = pixelData[pixelIndex]
                        minVal = min(minVal, val)
                        maxVal = max(maxVal, val)
                    }
                }
                
                let contrast = Int(maxVal) - Int(minVal)
                let threshold = (Int(minVal) + Int(maxVal)) / 2
                
                let currentIndex = (m * width + n) * bytesPerPixel
                let currentVal = Int(pixelData[currentIndex])
                
                let binaryValue: UInt8
                
                if contrast <= epsilon {
                    // Low contrast region
                    binaryValue = (threshold >= 128) ? 255 : 0
                } else {
                    binaryValue = (currentVal >= threshold) ? 255 : 0
                }
                
                outputData[currentIndex] = binaryValue
                outputData[currentIndex + 1] = binaryValue
                outputData[currentIndex + 2] = binaryValue
            }
        }
        
        return createImage(from: outputData, width: width, height: height)
    }
    
    // MARK: - Niblack Threshold
    func applyNiblackThreshold(to image: UIImage, r: Int, k: Double) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Convert to grayscale
        var grayData = [Double](repeating: 0, count: width * height)
        for i in 0..<(width * height) {
            let pixelIndex = i * bytesPerPixel
            let gray = Double((Int(pixelData[pixelIndex]) + Int(pixelData[pixelIndex + 1]) + Int(pixelData[pixelIndex + 2])) / 3)
            grayData[i] = gray
        }
        
        var outputData = pixelData
        
        for m in r..<(height - r) {
            for n in r..<(width - r) {
                var sum: Double = 0
                var sumSq: Double = 0
                let windowSize = (2 * r + 1) * (2 * r + 1)
                
                // Calculate mean and standard deviation in window
                for i in -r...r {
                    for j in -r...r {
                        let val = grayData[(m + i) * width + (n + j)]
                        sum += val
                        sumSq += val * val
                    }
                }
                
                let mean = sum / Double(windowSize)
                let variance = (sumSq / Double(windowSize)) - (mean * mean)
                let stdDev = sqrt(max(variance, 0))
                
                let threshold = mean + k * stdDev
                let currentVal = grayData[m * width + n]
                
                let outputIndex = (m * width + n) * bytesPerPixel
                let binaryValue: UInt8 = (currentVal >= threshold) ? 255 : 0
                
                outputData[outputIndex] = binaryValue
                outputData[outputIndex + 1] = binaryValue
                outputData[outputIndex + 2] = binaryValue
            }
        }
        
        return createImage(from: outputData, width: width, height: height)
    }
    
    // MARK: - Helper Methods
    private func createImage(from data: [UInt8], width: Int, height: Int) -> UIImage? {
        var mutableData = data
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        
        guard let provider = CGDataProvider(data: NSData(bytes: &mutableData, length: data.count)) else {
            return nil
        }
        
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
