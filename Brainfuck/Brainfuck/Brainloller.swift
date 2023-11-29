//
//  Brainloller.swift
//  Brainfuck
//
//  Created by Nicolas Seriot on 02.05.17.
//  Copyright © 2017 Nicolas Seriot. All rights reserved.
//

// https://esolangs.org/wiki/Brainloller

import AppKit

class Brainloller: NSObject {
    
    enum Direction {
        case north
        case east
        case south
        case west
        
        mutating func rotateClockwise() {
            switch self {
            case .north: self = .east
            case .east: self = .south
            case .south: self = .west
            case .west: self = .north
            }
        }
        
        mutating func rotateCounterClockwise() {
            switch self {
            case .north: self = .west
            case .west: self = .south
            case .south: self = .east
            case .east: self = .north
            }
        }
        
        func pixels() -> (x:Int, y:Int) {
            switch self {
            case .north: return (0,-1)
            case .west: return (-1,0)
            case .south: return (0,1)
            case .east: return (1,0)
            }
        }
    }
    
    enum BLError: Error {
        case CannotReadPath
        case CannotGetImageData
        case CannotGetImageBitmap
    }
    
    var bitmap : NSBitmapImageRep
    var direction : Direction = .east
    
    init(imagePath: String) throws {
        guard let image = NSImage(byReferencingFile: imagePath) else { throw BLError.CannotReadPath }
        guard let tiffData = image.tiffRepresentation else { throw BLError.CannotGetImageData }
        guard let bitmapRep = NSBitmapImageRep(data: tiffData) else { throw BLError.CannotGetImageBitmap }
        
        self.bitmap = bitmapRep
    }
    
    func rgbComponents(color c: NSColor) -> (r: UInt8, g: UInt8, b: UInt8) {
        //let c = color.usingColorSpaceName(NSCalibratedRGBColorSpace)!
        
        let r = UInt8(c.redComponent * 255)
        let g = UInt8(c.greenComponent * 255)
        let b = UInt8(c.blueComponent * 255)
        
        return (r,g,b)
    }
    
    func readInstruction(r: UInt8, g: UInt8, b:UInt8) -> String? {
        
        switch (r,g,b) {
        case (255,  0,  0): // red
            return ">"
        case (128,  0,  0): // darkred
            return "<"
        case (  0,255,  0): // green
            return "+"
        case (  0,128,  0): // darkgreen
            return "-"
        case (  0,  0,255): // blue
            return "."
        case (  0,  0,128): // darkblue
            return ","
        case (255,255,  0): // yellow
            return "["
        case (128,128,  0): // darkyellow
            return "]"
        case (  0,255,255): // cyan
            return "CW"
        case (  0,128,128): // darkcyan
            return "CCW"
        default:
            return nil
        }
    }
    
    func brainfuck() -> (coordinates: [(x: Int, y: Int)], brainfuck: String) {
        
        var x : Int = 0
        var y : Int = 0
        
        var s = ""
        
        var coords : [(x:Int, y:Int)] = []
        
        while let color = bitmap.colorAt(x: x, y: y) {
            
            coords += [(x: x, y: y)]
            
            let (r,g,b) = rgbComponents(color: color)
            
            if let i = readInstruction(r: r, g: g, b: b) {
                switch i {
                case "CW":
                    self.direction.rotateClockwise()
                case "CCW":
                    self.direction.rotateCounterClockwise()
                default:
                    s += i
                }
            } else {
                print("-- [\(x),\(y)] ignore (\(r),\(g),\(b))")
            }
            
            x += direction.pixels().x
            y += direction.pixels().y
            
            //print("\(x),\(y)")
        }
        
        return (coords, s)
    }
    
    func magnifiedProgramWithTrace(programPath: String, outPath: String, coordinates: [(x: Int, y: Int)]) {
        
        let FACTOR = 10
        
        let WIDTH = Int(self.bitmap.size.width) * FACTOR
        let HEIGHT = Int(self.bitmap.size.height) * FACTOR
        
        let imageRep = NSBitmapImageRep(
            bitmapDataPlanes:nil,
            pixelsWide: WIDTH,
            pixelsHigh: HEIGHT,
            bitsPerSample:8,
            samplesPerPixel:4,
            hasAlpha:true,
            isPlanar:false,
            colorSpaceName:NSColorSpaceName.deviceRGB,
            bytesPerRow: WIDTH * 4,
            bitsPerPixel:32)!
        
        let nsGraphicContext = NSGraphicsContext(bitmapImageRep: imageRep)!
        
        let c = nsGraphicContext.cgContext
        
        NSGraphicsContext.current = nsGraphicContext
        
        c.setAllowsAntialiasing(false)
        
        // makes coordinates start upper left
        c.translateBy(x: 0, y: CGFloat(HEIGHT))
        c.scaleBy(x: 1.0, y: -1.0)
        
        let strikeColor = NSColor.black
        
        c.saveGState()
        
        // align to the pixel grid
        c.translateBy(x: 0.5, y: 0.5)
        
        // copy program but magnified
        
        for y in 0..<Int(self.bitmap.size.height) {
            for x in 0..<Int(self.bitmap.size.width) {
                let y_ = y * FACTOR
                let x_ = x * FACTOR
                let c = self.bitmap.colorAt(x: x, y: y)!
                c.setFill()
                let rect = NSMakeRect(CGFloat(x_), CGFloat(y_), CGFloat(FACTOR), CGFloat(FACTOR))
                NSBezierPath.fill(rect)
            }
        }
        
        // trace exec coordinates

        c.setStrokeColor(strikeColor.cgColor);
        
        c.setLineCap(.square)
        
        for (i,coords) in coordinates.enumerated() {
            let x = coords.x * FACTOR + FACTOR / 2
            let y = coords.y * FACTOR + FACTOR / 2
            
            if i == 0 {
                c.move(to: CGPoint(x: x, y: y))
            } else {
                c.addLine(to: CGPoint(x: x, y: y))
            }
        }
 
        c.strokePath()

        c.restoreGState()
        
        guard let data = imageRep.representation(using: .png, properties: [:]) else {
            print("\(#file) \(#function) cannot get PNG data from bitmap")
            return
        }
        
        do {
            try data.write(to: URL(fileURLWithPath: outPath), options: [])
        } catch let e {
            print(e)
        }
        
    }
}
