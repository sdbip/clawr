import Testing
import Parser

@Suite("Variable Declarations")
struct VariableDeclarationTests {

    @Test("Explicit integer")
    func explicit_integer() async throws {
        let source = "let x: integer = 2"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration("x", semantics: .immutable, type: "integer", initializer: .integer(2))
        ])
    }

    @Test("Inferred integer")
    func inferred_integer() async throws {
        let source = "let x = 2"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration("x", semantics: .immutable, type: "integer", initializer: .integer(2))
        ])
    }

    @Test("Explicit real")
    func explicit_real() async throws {
        let source = "let x: real = 2"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration("x", semantics: .immutable, type: "real", initializer: .integer(2))
        ])
    }

    @Test("Inferred real")
    func inferred_real() async throws {
        let source = "let x = 2.0"
        let ast = try parse(source)
        #expect(ast == [
            .variableDeclaration("x", semantics: .immutable, type: "real", initializer: .real(2.0))
        ])
    }
}
