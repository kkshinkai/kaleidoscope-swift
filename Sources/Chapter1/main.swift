enum Token {
    case eof, def, extern
    case identifier(String)
    case number(Double)
    case notation(String)
}

struct PeekableIterator<Element>: IteratorProtocol {
    private var iterator: AnyIterator<Element>
    private var lastElement: Element?
    
    init<I: IteratorProtocol>(iterator: I) where I.Element == Element {
        self.iterator = AnyIterator(iterator)
    }
    
    mutating func peek() -> Element? {
        lastElement = lastElement ?? iterator.next()
        return lastElement
    }
    
    mutating func next() -> Element? {
        defer { lastElement = nil }
        return lastElement ?? iterator.next()
    }
}

extension Sequence {
    func peekable() -> PeekableIterator<Element> {
        PeekableIterator(iterator: self.makeIterator())
    }
}

func lex(_ source: String) -> [Token] {
    var stream = source.peekable()
    var tokens: [Token] = []
    
    while let next = stream.peek() {
        // (1) Skip any whitespace
        if next.isWhitespace {
            _ = stream.next()
        }
        
        // (2) Identifier: [a-zA-Z][a-zA-Z0-9]
        else if next.isLetter {
            var buffer = ""
            while let next = stream.peek(), next.isLetter || next.isNumber {
                buffer.append(stream.next()!)
            }
            
            switch buffer {
            case "def":    tokens.append(.def)
            case "extern": tokens.append(.extern)
            default:       tokens.append(.identifier(buffer))
            }
        }
        
        // (3) Number: [0-9.]+
        else if next.isNumber || next == "." {
            var buffer = "", hasDot = false
            while let next = stream.peek(), next.isNumber || !hasDot && next == "." {
                if next == "." { hasDot.toggle() }
                buffer.append(stream.next()!)
            }
            tokens.append(.number(Double(buffer)!))
        }
        
        // (4) Comment
        else if next == "#" {
            while let next = stream.peek(), next != "\r", next != "\n" {
                _ = stream.next()
            }
        }
        
        // (5) Else
        else {
            tokens.append(.notation(String(stream.next()!)))
        }
    }
    
    return tokens
}

print("> ", terminator: "")
while let line = readLine(), line != "quit" {
    print(lex(line))
    print("> ", terminator: "")
}
