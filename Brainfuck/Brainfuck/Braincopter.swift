//
//  Braincopter.swift
//  Brainfuck
//
//  Created by Nicolas Seriot on 06.05.17.
//  Copyright © 2017 Nicolas Seriot. All rights reserved.
//

// https://esolangs.org/wiki/Braincopter

import Foundation

class Braincopter: Brainloller {

    override func readInstruction(r: UInt8, g: UInt8, b:UInt8) -> String? {
        
        let command = (65536 * Int(r) + 256 * Int(g) + Int(b)) % 11
        
        switch command {
        case 0:
            return ">"
        case 1:
            return "<"
        case 2:
            return "+"
        case 3:
            return "-"
        case 4:
            return "."
        case 5:
            return ","
        case 6:
            return "["
        case 7:
            return "]"
        case 8:
            return "CW"
        case 9:
            return "CCW"
        default:
            return nil
        }
    }

}
