//
//  main.swift
//  Brainfuck
//
//  Created by nst on 01.05.17.
//  Copyright © 2017 Nicolas Seriot. All rights reserved.
//

import Foundation

let helloWorld = "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>."

func f1() {
    let b = try! Brainfuck(helloWorld)
    let result = try! b.run()
    print(result)
}

func f2() {
    let b = try! Brainfuck(helloWorld, userInput: "", dataSize: 10)
    let result = try! b.run()
    print(result)
}

func f3() {
    do {
        let b = try Brainfuck(helloWorld)
        
        while b.canRun() {
            if let s = try b.step() {
                print(s)
            }
        }
    } catch let e {
        print(e)
    }
}

func f4() {
    do {
        let b = try Brainfuck("++++++[>++++++<-]>.") // 6x6 == 0x24 == '$'
        
        while b.canRun() {
            print("------------------------------------------------------------------------------------")
            b.printStep()
            b.printInstructions()
            b.printData(upToIndex: 10)
            
            if let putByte = try b.step() {
                print(" PUT: " + String(format: "%02X", putByte))
//                let s = Character(UnicodeScalar(putByte))
//                print(s, separator: "", terminator: "")
            }
        }
        
        print("------------------------------------------------------------------------------------")
        b.printExecutionSummary()
        
//        print(b.outputString())
        
    } catch let e {
        print(e)
    }
}

f1()
f2()
f3()
f4()
