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
}
