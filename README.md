# Brainfuck

`Brainfuck.swift` is a flexible Brainfuck interpreter in Swift 3.1.

It comes with unit tests and tracing / debuging functions.

Here are several ways to use it, given the following program:

```let helloWorld = "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>."```

## 1. Simple call

```Swift
let b = try! Brainfuck(helloWorld)
let result = try! b.run()
```

Result: `Hello World!\n`

## 2. Use optional parameters

```Swift
let b = try! Brainfuck(helloWorld, userInput: "", dataSize: 32)
let result = try! b.run()
```

Result: `Hello World!\n`

## 3. Call step by step

```Swift
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
```

Output:

```
72
101
108
108
111
32
87
111
114
108
100
33
10
```

## 4. Print state at each step

```Swift
do {
    let b = try Brainfuck("++++++[>++++++<-]>.") // 6x6 == 0x24 == '$'
    
    while b.canRun() {
        print("-------------------------------------------------------------")
        b.printStep()
        b.printInstructions()
        b.printData(upToIndex: 10)
        
        if let putByte = try b.step() {
            print(" PUT: " + String(format: "%02X", putByte))
        }
    }
    
    print("-------------------------------------------------------------")
    b.printExecutionSummary()
    
} catch let e {
    print(e)
}
```

Output:

```
...
-------------------------------------------------------------
STEP: 73
PROG: ++++++[>++++++<-]>.
                       ^ 17
DATA: 00 24 00 00 00 00 00 00 00 00 00
      ^^ 0
-------------------------------------------------------------
STEP: 74
PROG: ++++++[>++++++<-]>.
                        ^ 18
DATA: 00 24 00 00 00 00 00 00 00 00 00
         ^^ 1
 PUT: 24
-------------------------------------------------------------
SUMMARY: program stopped after 75 step(s) with output:
    HEX: 24
    STR: $
```
