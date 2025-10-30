import Testing
import Codegen

@Suite("Codegen")
struct CodegenTests {
    @Test("Empty main function")
    func empty_main() async throws {
        let result = try run(ir: [
            .function("main", returns: "int", parameters: [], body: [
                .return(.literal("0"))
            ])
        ])
        #expect(result == "")
    }

    @Test("Print integer")
    func print_integer() async throws {
        let result = try run(
            ir: [
                .function("main", returns: "int", parameters: [], body: [
                    .call("printf", arguments: [
                        .literal(#""%d\n""#),
                        .literal("42"),
                    ])
                ])
            ])
        #expect(result == "42\n")
    }
}
