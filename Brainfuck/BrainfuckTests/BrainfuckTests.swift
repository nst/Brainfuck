//
//  BrainfuckTests.swift
//  BrainfuckTests
//
//  Created by nst on 01.05.17.
//  Copyright © 2017 Nicolas Seriot. All rights reserved.
//

import XCTest

func compileAndRun(instructions: String, userInput: String = "", dataSize: Int = 1000) throws -> Brainfuck {
    let b = try Brainfuck(instructions, userInput: userInput, dataSize: dataSize)
    let _ = try b.run()
    return b
}

func bfToString(_ instructions: String) -> String {
    do {
        return try compileAndRun(instructions: instructions).outputString()
    } catch let e {
        XCTFail("\(e)")
        return ""
    }
}

func bfToBuffer(_ instructions: String) -> [UInt8] {
    do {
        return try compileAndRun(instructions: instructions).outputBuffer()
    } catch let e {
        XCTFail("\(e)")
        return []
    }
}

class BrainfuckTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPrograms() {
        XCTAssertEqual(bfToBuffer("+ asdasdas +++."), [4])
        
        XCTAssertEqual(bfToBuffer("++++."), [4])
        
        let helloWorldSingleLoop = "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>."
        XCTAssertEqual(bfToString(helloWorldSingleLoop), "Hello World!\n")
        
        let helloWorldNestedLoops = "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
        XCTAssertEqual(bfToString(helloWorldNestedLoops), "Hello World!\n")
        
        let printThreeInputChars = ",.,.,."
        let b = try! compileAndRun(instructions: printThreeInputChars, userInput: "asd")
        XCTAssertEqual(b.outputString(), "asd")
    }
    
    func testCompilationErrors() {
        do {
            let _ = try Brainfuck(">[>")
            XCTFail()
        } catch let e {
            switch e {
            case Brainfuck.BFError.LoopStartUnbalanced(index: 1):
                ()
            default:
                XCTFail()
            }
        }
        
        do {
            let _ = try Brainfuck("[]]")
            XCTFail()
        } catch let e {
            switch e {
            case Brainfuck.BFError.LoopStopUnbalanced(index: 2):
                ()
            default:
                XCTFail()
            }
        }
    }
    
    func testRuntimeErrors() {
        do {
            let b = try compileAndRun(instructions: "+<+")
            let _ = try b.run()
            XCTFail()
        } catch let e {
            switch e {
            case Brainfuck.BFError.DataPointerBelowZero(ip: 2):
                ()
            default:
                print(e)
                XCTFail()
            }
        }
        
        do {
            let b = try compileAndRun(instructions: "+>+>+", userInput: "", dataSize: 2)
            let _ = try b.run()
            XCTFail()
        } catch let e {
            switch e {
            case Brainfuck.BFError.DataPointerBeyondBounds(ip: 4):
                ()
            default:
                print(e)
                XCTFail()
            }
        }
        
        do {
            let b = try compileAndRun(instructions: "+-,", userInput: "")
            let _ = try b.run()
            XCTFail()
        } catch let e {
            switch e {
            case Brainfuck.BFError.CannotReadEmptyInputBuffer(ip: 2):
                ()
            default:
                print(e)
                XCTFail()
            }
        }
    }
    
    func testBrainloller() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.pathForImageResource("fibonacci") else {
            XCTFail()
            return
        }
        
        do {
            let b = try Brainloller(imagePath: path)
            let (_, s) = b.brainfuck()
            
            XCTAssertEqual(s, "++++++++++++++++++++++++++++++++++++++++++++>++++++++++++++++++++++++++++++++>++++++++++++++++>>+<<[>>>>++++++++++<<[->+>-[>+>>]>[+[-<+>]>+>>]<<<<<<]>[<+>-]>[-]>>>++++++++++<[->-[>+>>]>[+[-<+>]>+>>]<<<<<]>[-]>>[++++++++++++++++++++++++++++++++++++++++++++++++.[-]]<[++++++++++++++++++++++++++++++++++++++++++++++++.[-]]<<<++++++++++++++++++++++++++++++++++++++++++++++++.[-]<<<<<<<.>.>>[>>+<<-]>[>+<<+>-]>[<+>-]<<<-]<<++...")
        } catch let e {
            print(e)
            XCTFail()
        }
    }
    
    func testBraincopter1() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.pathForImageResource("braincopter1") else {
            XCTFail()
            return
        }
        
        do {
            let b = try Braincopter(imagePath: path)
            let (_, s) = b.brainfuck()
            
            XCTAssertEqual(s, "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.")
        } catch let e {
            print(e)
            XCTFail()
        }
    }
    
    func testBraincopter2() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.pathForImageResource("braincopter2") else {
            XCTFail()
            return
        }
        
        do {
            let b = try Braincopter(imagePath: path)
            let (_, s) = b.brainfuck()
            
            XCTAssertEqual(s, ">++++++++++[<++++++++++>-]>>>>>>>>>>>>>>>>++++[>++++<-]>[<<<<<<<++>+++>++++>++++++>+++++++>+++++++>++++>-]<++<+++++<++++++++++<+++++++++<++++++<<<<<<<<<<<<<[>+>+>[-]>>>>[-]>[-]<<<<<<<[>>>>>>+>+<<<<<<<-]>>>>>>[<<<<<<+>>>>>>-]+>---[<->[-]]<[>>>>>>.>.>..<<<<<<<<<<<<+<<[-]>>>>>>-]<<<<<[>>>>>+>+<<<<<<-]>>>>>[<<<<<+>>>>>-]+>-----[<->[-]]<[>>>>>>>>>>.<.<..<<<<<<<<<<<<+<[-]>>>>>-]<+>[-]>[-]>[-]<<<[>+>+>+<<<-]>[<+>-]+>----------[<->[-]]<[<<+>[-]>-]>[-]>[-]<<<<[>>+>+>+<<<<-]>>[<<+>>-]+>----------[<->[-]]<[<<<+>[-]>>-][-]>[-]<<<<<[>>>>+>+<<<<<-]>>>>[<<<<+>>>>-]+>[<->[-]]<[[-]>[-]<<<<[>>>+>+<<<<-]>>>>[<<<<+>>>>-]<[>++++++++[<++++++>-]<.-.[-]][-]>[-]<<<[>>+>+<<<-]>>>[<<<+>>>-]<[>++++++++[<++++++>-]<.[-]][-]>[-]<<[>+>+<<-]>>[<<+>>-]++++++++[<++++++>-]<.[-]]>>>>.<<<<<<<<<<<-]")
        } catch let e {
            print(e)
            XCTFail()
        }
    }
}
