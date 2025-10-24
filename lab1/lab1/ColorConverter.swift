//
//  ColorConverter.swift
//  lab1
//
//  Created by Yaraslau Merynau on 16.10.25.
//


import UIKit

class ColorConverter {
    
    // MARK: - RGB to HSV
    static func rgbToHSV(r: CGFloat, g: CGFloat, b: CGFloat) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        let max = max(r, g, b)
        let min = min(r, g, b)
        let delta = max - min
        
        var h: CGFloat = 0
        let s: CGFloat = max == 0 ? 0 : delta / max
        let v: CGFloat = max
        
        if delta != 0 {
            if max == r {
                h = 60 * (((g - b) / delta).truncatingRemainder(dividingBy: 6))
            } else if max == g {
                h = 60 * (((b - r) / delta) + 2)
            } else {
                h = 60 * (((r - g) / delta) + 4)
            }
        }
        
        if h < 0 {
            h += 360
        }
        
        return (h, s, v)
    }
    
    // MARK: - HSV to RGB
    static func hsvToRGB(h: CGFloat, s: CGFloat, v: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let c = v * s
        let x = c * (1 - abs(((h / 60).truncatingRemainder(dividingBy: 2)) - 1))
        let m = v - c
        
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        
        if h >= 0 && h < 60 {
            r = c; g = x; b = 0
        } else if h >= 60 && h < 120 {
            r = x; g = c; b = 0
        } else if h >= 120 && h < 180 {
            r = 0; g = c; b = x
        } else if h >= 180 && h < 240 {
            r = 0; g = x; b = c
        } else if h >= 240 && h < 300 {
            r = x; g = 0; b = c
        } else {
            r = c; g = 0; b = x
        }
        
        return (r + m, g + m, b + m)
    }
    
    // MARK: - RGB to CMYK
    static func rgbToCMYK(r: CGFloat, g: CGFloat, b: CGFloat) -> (c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) {
        let k = 1 - max(r, g, b)
        
        if k == 1 {
            return (0, 0, 0, 1)
        }
        
        let c = (1 - r - k) / (1 - k)
        let m = (1 - g - k) / (1 - k)
        let y = (1 - b - k) / (1 - k)
        
        return (c, m, y, k)
    }
    
    // MARK: - CMYK to RGB
    static func cmykToRGB(c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let r = (1 - c) * (1 - k)
        let g = (1 - m) * (1 - k)
        let b = (1 - y) * (1 - k)
        
        return (r, g, b)
    }
}
