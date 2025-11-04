import Testing
import Lexer
@testable import Parser

@Suite("Object Declarations")
struct ObjectDeclarationTests {

    @Test(arguments: ["object", "object O", "object O {"])
    func unexpected_end(_ source: String) async throws {
        let error = try #require(throws: ParserError.self) { try parse(source) }
        guard case .unexpectedEOF = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test(arguments: ["object 12 {}", "object S 1"])
    func invalid_token(_ source: String) async throws {
        let error = try #require(throws: ParserError.self) { try parse(source)}
        guard case .invalidToken = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test
    func empty_object() async throws {
        let ast = try parse("object S {}")
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
        ))])
    }

    @Test
    func single_field() async throws {
        let ast = try parse("""
            object S {
            data:
                x: integer
            }
            """)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            fields: [Variable(name: "x", semantics: .isolated, type: .builtin(.integer))],
        ))])
    }

    @Test
    func multiple_fields_on_single_line() async throws {
        let ast = try parse("object S { data: x: integer, y: bitfield }")
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            fields: [
                Variable(name: "x", semantics: .isolated, type: .builtin(.integer)),
                Variable(name: "y", semantics: .isolated, type: .builtin(.bitfield)),
            ],
        ))])
    }

    @Test
    func multiple_fields_with_newline_separator() async throws {
        let source = """
            object S {
            data:
                x: integer
                y: bitfield
            }
            """
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            fields: [
                Variable(name: "x", semantics: .isolated, type: .builtin(.integer)),
                Variable(name: "y", semantics: .isolated, type: .builtin(.bitfield)),
            ],
        ))])
    }

    @Test
    func multiple_fields_with_trailing_comma() async throws {
        let source = "object S { data: x: integer, y: bitfield, }"
        let ast = try parse(source)
        #expect(ast == [.objectDeclaration(Object(
            name: "S",
            fields: [
                Variable(name: "x", semantics: .isolated, type: .builtin(.integer)),
                Variable(name: "y", semantics: .isolated, type: .builtin(.bitfield)),
            ],
        ))])
    }
}
