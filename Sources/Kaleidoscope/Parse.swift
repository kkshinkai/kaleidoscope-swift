
enum AST {
    case number(Double)
    case variable(String)
    indirect case binary(operator: String, lhs: AST, rhs: AST)
    case call(callee: String, arguments: [AST])
}

struct Prototype {
    let name: String, parameters: [String]
}

struct Function {
    let prototype: Prototype, body: AST
}

func reportError(_ message: String) -> AST? {
    print("Error: \(message)")
    return nil
}

func reportPrototypeError(_ message: String) -> Prototype? {
    print("Errpr: \(message)")
    return nil
}

// numberexpr ::= number
func parseNumberExpression(_ stream: inout PeekableIterator<Token>) -> AST? {
    guard case let .number(n) = stream.next()! else { fatalError("unreachable") }
    return .number(n)
}

// parenexpr ::= '(' expression ')'
func parseParenthesesnExpression(_ stream: inout PeekableIterator<Token>) -> AST? {
    _ = stream.next() // eat '('
    
    guard let expression = parseExpression(&stream) else { return nil } // eat expression
    
    guard stream.peek() == .some(.notation(")")) else { // eat ')'
        return reportError("expected ')'")
    }
    _ = stream.next()
    
    return expression
}


// identifierexpr
//      ::= identifier
//      ::= identifier '(' expression* ')'
func parseIdentifierExpression(_ stream: inout PeekableIterator<Token>) -> AST? {
    guard case let .identifier(identifier) = stream.next()! else { // eat identifier
        fatalError("unreachable")
    }

    if stream.peek() != .some(.notation("(")) {
        return .variable(identifier)
    }
    
    _ = stream.next() // eat '('

    var arguments: [AST] = []
    if stream.peek() != .some(.notation(")")) {
        while true {
            if let argument = parseExpression(&stream) {
                arguments.append(argument)
            } else { return nil }

            if stream.peek() == .some(.notation(")")) {
                break
            } else if stream.peek() == .some(.notation(",")) {
                _ = stream.next() // eat ','
            } else {
                return reportError("Expected ')' or ',' in argument list")
            }
        }
    }
    _ = stream.next() // eat ')'
    
    return .call(callee: identifier, arguments: arguments)
}

// primary
//     ::= identifierexpr
//     ::= numberexpr
//     ::= parenexpr
func parsePrimary(_ stream: inout PeekableIterator<Token>) -> AST? {
    switch stream.peek() {
    case .identifier:
        return parseIdentifierExpression(&stream)
    case .number:
        return parseNumberExpression(&stream)
    case .notation("("):
        return parseParenthesesnExpression(&stream)
    default:
        _ = stream.next()
        return reportError("unknow token when expecting an expression")
    }
}

func parseExpression(_ stream: inout PeekableIterator<Token>) -> AST? {
    guard var lhs = parsePrimary(&stream) else { return nil }
    return parseBinaryOperatorRHS(&stream, lhs: &lhs)
}

let binaryOperatorPrecedence: [Token?: Int] =
    [.notation("<"): 10, .notation("+"): 20, .notation("-"): 20, .notation("*"): 40]

// binoprhs
//     ::= ('+' primary)*
func parseBinaryOperatorRHS(_ stream: inout PeekableIterator<Token>,
                            lhs: inout AST, expressionPrecedence: Int = 0) -> AST? {
    while true {
        let precedence = binaryOperatorPrecedence[stream.peek(), default: -1]
        
        // If this is a binop that binds at least as tightly as the current
        // binop, consume it, otherwise we are done.
        if precedence < expressionPrecedence {
            return lhs
        }
        
        guard case let .notation(`operator`) = stream.next() else { // eat operator
            fatalError("unreachable")
        }
        
        // Parse the primary expression after the binary operator.
        guard var rhs = parsePrimary(&stream) else { return nil }
        
        // If BinOp binds less tightly with RHS than the operator after RHS, let
        // the pending operator take RHS as its LHS.
        let nextPrecedence = binaryOperatorPrecedence[stream.peek(), default: -1]
        if precedence < nextPrecedence {
            rhs = parseBinaryOperatorRHS(&stream, lhs: &rhs, expressionPrecedence: precedence + 1)!
        }
        lhs = .binary(operator: `operator`, lhs: lhs, rhs: rhs)
    }
}

// prototype
//     ::= id '(' id* ')'
func parsePrototype(_ stream: inout PeekableIterator<Token>) -> Prototype? {
    guard case let .some(.identifier(identifier)) = stream.peek() else {
        return reportPrototypeError("Expected function name in prototype")
    }
    _ = stream.next()
    
    guard stream.peek() == .some(.notation("(")) else {
        return reportPrototypeError("Expected '(' in prototype")
    }
    _ = stream.next()
    
    var parameters: [String] = []
    while case let .identifier(parameter) = stream.peek() {
        parameters.append(parameter)
        print(stream.next()!)
//        _ = stream.next()
    }
    
    print(stream.peek()!)
    
    guard stream.peek() == .some(.notation(")")) else {
        return reportPrototypeError("Expected ')' in prototype")
    }
    _ = stream.next() // eat ')'
    
    return Prototype(name: identifier, parameters: parameters)
}

// definition ::= 'def' prototype expression
func parseDefinition(_ stream: inout PeekableIterator<Token>) -> Function? {
//    _ = stream.next() // eat def
    assert(stream.next() == .some(.def))
    guard let prototype = parsePrototype(&stream) else { return nil }
    
    if let expression = parseExpression(&stream) {
        return Function(prototype: prototype, body: expression)
    } else { return nil }
}


// external ::= 'extern' prototype
func parseExtern(_ stream: inout PeekableIterator<Token>) -> Prototype? {
    _ = stream.next()  // eat extern
    return parsePrototype(&stream)
}

func handleDefinition(_ stream: inout PeekableIterator<Token>) {
    if let _ = parseDefinition(&stream) {
        print("Parsed a function definition.")
    } else {
        parseAll(&stream)
    }
}

func handleExtern(_ stream: inout PeekableIterator<Token>) {
    if let _ = parseExtern(&stream) {
        print("Parsed a function extern.")
    } else {
        parseAll(&stream)
    }
}

func parseTopLevelExpression(_ stream: inout PeekableIterator<Token>) -> Function? {
    if let expression = parseExpression(&stream) {
        let prototype = Prototype(name: "", parameters: [])
        return Function(prototype: prototype, body: expression)
    } else {
        return nil
    }
}

func handleTopLevelExpression(_ stream: inout PeekableIterator<Token>) {
    if let _ = parseTopLevelExpression(&stream) {
        print("Parsed a top level expression")
    } else {
        parseAll(&stream)
    }
}

func parseAll(_ stream: inout PeekableIterator<Token>) {
    // guard let next = stream.peek() else {
    //    fatalError("expect more tokens, but the input stream touch the end")
    // }
    
    while let next = stream.peek() {
        switch next {
        case .notation(";"):
            continue // ignore top-level semicolons
        case .def:
            handleDefinition(&stream)
        case .extern:
            handleExtern(&stream)
        default:
            handleTopLevelExpression(&stream)
        }
    }
    
    return
}

func parse(_ tokens: [Token]) {
    var stream = tokens.peekable()
    parseAll(&stream)
}
