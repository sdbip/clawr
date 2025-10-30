import Testing
import Codegen

@Suite("Codegen")
struct CodegenTests {

    @Test("Print integer")
    func print_integer() async throws {
        let result = try run(
            ir: [
                exec([
                    .call("printf", arguments: [
                        .literal(#""%d\n""#),
                        .literal("42"),
                    ])
                ])
            ])
        #expect(result == "42\n")
    }

    @Test("Print boxed integer")
    func print_boxed_integer() async throws {
        let result = try run(
            ir: [
                exec([
                    .variable(
                        "s",
                        type: "string*",
                        initializer: .call(
                            "integer_toString",
                            arguments: [.literal("42")]
                        )
                    ),
                    .call("print", arguments: [.literal("s")]),
                    .assign("s", value: .call("oo_release", arguments: [.literal("s")])),
                ])
            ])
        #expect(result == "42\n")
    }
}

func exec(_ body: [Statement]) -> Statement {
    return .function("main", returns: "int", parameters: [], body: body.appending(.return(.literal("0"))))
}

extension Array {
    func appending(_ element: Element) -> Self {
        var s = self
        s.append(element)
        return s
    }
}
