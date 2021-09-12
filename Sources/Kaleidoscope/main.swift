import LLVM

print("> ", terminator: "")
while let line = readLine(), line != "quit" {
    let tokens = lex(line)
    parse(tokens)
    print("> ", terminator: "")
}