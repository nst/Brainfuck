//
//  Brainfuck.swift
//  Brainfuck
//
//  Created by Nicolas Seriot on 01.05.17.
//  Copyright © 2017 Nicolas Seriot. All rights reserved.
//

import Foundation

class Brainfuck: NSObject {
    
    enum Instruction {
        case moveRight
        case moveLeft
        case increment
        case decrement
        case put
        case get
        case loopStart(to:Int)
        case loopStop(from:Int)
        
        init?(rawValue c: Character) {
            switch c {
            case ">": self = .moveRight
            case "<": self = .moveLeft
            case "+": self = .increment
            case "-": self = .decrement
            case ".": self = .put
            case ",": self = .get
            case "[": self = .loopStart(to:0)
            case "]": self = .loopStop(from:0)
            default: return nil
            }
        }
        
        func description(showLoopMatch:Bool = false) -> String {
            switch self {
            case .moveRight: return ">"
            case .moveLeft: return "<"
            case .increment: return "+"
            case .decrement: return "-"
            case .put: return "."
            case .get: return ","
            case let .loopStart(to): return showLoopMatch ? "[\(to)" : "["
            case let .loopStop(from): return showLoopMatch ? "\(from)]" : "]"
            }
        }
    }
    
    var stepCounter : Int = 0
    
    // program
    var instructions : [Instruction] = []
    var ip : Int = 0 // instruction pointer
    
    // data
    var data : [UInt8] = []
    var dp : Int = 0 // data pointer
    
    // I/O
    var input = [UInt8]("".utf8)
    var output = [UInt8]("".utf8)
    
    enum BFError: Error {
        case LoopStartUnbalanced(index:Int)
        case LoopStopUnbalanced(index:Int)
        case DataPointerBelowZero(ip:Int)
        case DataPointerBeyondBounds(ip:Int)
        case CannotReadEmptyInputBuffer(ip:Int)
    }
    
    init(_ s: String, userInput: String = "", dataSize: Int = 30000) throws {
        
        // 1. initialize data
        self.data = Array(repeating: 0, count: dataSize)
        
        // 2. sanitize instructions
        self.instructions = s.characters.flatMap { Instruction(rawValue:$0) }
        
        // 3. store user input
        self.input = [UInt8](userInput.utf8)
        
        // 4. associate matching indices to loops start and end
        
        var loopStartStack : [Int] = []
        
        for (i, instruction) in instructions.enumerated()  {
            switch instruction {
            case .loopStart:
                loopStartStack.append(i)
            case .loopStop:
                guard let loopStartIndex = loopStartStack.popLast() else { throw BFError.LoopStopUnbalanced(index:i) }
                instructions[loopStartIndex] = .loopStart(to: i)
                instructions[i] = .loopStop(from: loopStartIndex)
            default:
                ()
            }
        }
        
        // 5. throw if unbalanced brackets
        if let unmatchedStartIndex = loopStartStack.first {
            throw BFError.LoopStartUnbalanced(index: unmatchedStartIndex)
        }
    }
    
    func canRun() -> Bool {
        return ip < instructions.count
    }
    
    func run() throws -> String {
        while self.canRun() {
            _ = try self.step()
        }
        return self.outputString()
    }
    
    func step() throws -> UInt8? {
        
        assert(ip < instructions.count)
        
        stepCounter += 1
        
        var putByte : UInt8? = nil
        
        let i = instructions[ip]
        
        switch i {
        case .moveRight:
            dp += 1
        case .moveLeft:
            dp -= 1
        case .increment:
            data[dp] = data[dp] &+ 1
        case .decrement:
            data[dp] = data[dp] &- 1
        case .put:
            let byte = data[dp]
            output.append(byte)
            putByte = byte
        case .get:
            guard input.count > 0 else { throw BFError.CannotReadEmptyInputBuffer(ip:ip) } // TODO: be interactive instead?
            data[dp] = input.removeFirst()
        case let .loopStart(to):
            if data[dp] == 0 {
                ip = to
            }
        case let .loopStop(from):
            ip = from - 1
        }
        
        ip += 1
        
        if dp < 0 {
            throw BFError.DataPointerBelowZero(ip:ip)
        } else if dp >= data.count {
            throw BFError.DataPointerBeyondBounds(ip:ip)
        }
        
        return putByte
    }
}

// DEBUG extension
extension Brainfuck {
    
    func printStep() {
        print("STEP:", stepCounter)
    }
    
    func printData(upToIndex: Int? = nil) {
        var subData = data
        if let upIndex = upToIndex {
            subData = Array(data[0...upIndex])
        }
        print("DATA:", subData.map { String(format: "%02X", $0) }.joined(separator: " "))
        print("".padding(toLength: 6 + 3*dp, withPad: " ", startingAt: 0) + "^^ \(dp)")
    }
    
    func printInstructions() {
        print("PROG:", instructions.map { $0.description(showLoopMatch:false) }.joined())
        print("".padding(toLength: 6 + ip, withPad: " ", startingAt: 0) + "^ \(ip)")
    }
    
    func printExecutionSummary() {
        print("SUMMARY: program stopped after \(stepCounter) step(s) with output:")
        
        let s = output.map { String(format: "%02X", $0) }.joined(separator: " ")
        print("    HEX: \(s)")
        print("    STR: \(outputString())")
    }
    
    func outputBuffer() -> [UInt8] {
        return output
    }
    
    func outputString() -> String {
        return output.map { String(UnicodeScalar(Int($0))!) }.joined()
    }
}
