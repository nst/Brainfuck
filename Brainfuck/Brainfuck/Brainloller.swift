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
    
    enum Heading {
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
    var heading : Heading = .east
    
    init(imagePath: String) throws {
        guard let image = NSImage(byReferencingFile: imagePath) else { throw BLError.CannotReadPath }
        guard let tiffData = image.tiffRepresentation else { throw BLError.CannotGetImageData }
        guard let bitmapRep = NSBitmapImageRep(data: tiffData) else { throw BLError.CannotGetImageBitmap }
        
        self.bitmap = bitmapRep
    }
    
    func rgbComponents(color c: NSColor) -> (r: UInt8, g: UInt8, b: UInt8) {
        //let c = color.usingColorSpaceName(NSCalibratedRGBColorSpace)!
        
        var r = UInt8(c.redComponent * 255)
        var g = UInt8(c.greenComponent * 255)
        var b = UInt8(c.blueComponent * 255)
        
        // hack
        if r == 129 { r = 128 }
        if g == 129 { g = 128 }
        if b == 129 { b = 128 }
        
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
    
    func brainfuck() -> String {
        
        var x : Int = 0
        var y : Int = 0
        
        var s = ""
        
        while let color = bitmap.colorAt(x: x, y: y) {
            
            let (r,g,b) = rgbComponents(color: color)
            
            if let i = readInstruction(r: r, g: g, b: b) {
                switch i {
                case "CW":
                    self.heading.rotateClockwise()
                case "CCW":
                    self.heading.rotateCounterClockwise()
                default:
                    s += i
                }
            } else {
                print("-- [\(x),\(y)] ignore (\(r),\(g),\(b))")
            }
            
            x += heading.pixels().x
            y += heading.pixels().y
        }
        
        return s
    }
}
