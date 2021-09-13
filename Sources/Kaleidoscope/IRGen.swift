import LLVM

let context = Context()
var module = Module(name: "main")
let builder = IRBuilder(module: module)
var namedValues: [String: IRValue] = [:]

func generateIR(for ast: AST) -> IRValue? {
    switch ast {
    case .number(let n):
        return FloatType.double.constant(n)
    case .variable(let name):
        guard let value = namedValues[name] else {
            fatalError("unknown variable name")
        }
        return value.asLLVM()
    case let .binary(`operator`, lhs, rhs):
        guard let l = generateIR(for: lhs), let r = generateIR(for: rhs) else {
            return nil
        }

        switch `operator` {
        case "+": return builder.buildAdd(l, r, name: "add")
        case "-": return builder.buildSub(l, r, name: "sub")
        case "*": return builder.buildMul(l, r, name: "mul")
        case "<": return builder.buildFCmp(l, r, .unorderedLessThan, name: "boolCmp")
        default:  fatalError("invalid binary operator")
        }
    case let .call(callee, arguments):
        guard let function = module.function(named: callee) else { return nil }
        guard function.parameterCount == arguments.count else {
            fatalError("incorrect arguments count")
        }
        var argumentsIR = arguments.compactMap(generateIR)
        return builder.buildCall(function, args: argumentsIR, name: "call")
    }
}