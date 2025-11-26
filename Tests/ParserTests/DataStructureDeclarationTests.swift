import Testing
import Lexer
@testable import Parser

@Suite("Data Structure Declarations")
struct DataStructureDeclarationTests {
    @Test(arguments: ["data", "data S", "data S {"])
    func unexpected_end(_ source: String) async throws {
        let error = try #require(throws: ParserError.self) { try parse(source) }
        guard case .unexpectedEOF = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test(arguments: ["data 12 {}", "data S 1"])
    func invalid_token(_ source: String) async throws {
        let error = try #require(throws: ParserError.self) { try parse(source)}
        guard case .invalidToken = error else {
            Issue.record("Did not throw the expected error, was: \(error)")
            return
        }
    }

    @Test
    func empty_data() async throws {
        let ast = try parse("data S {}")
        #expect(ast == [.dataStructureDeclaration(DataStructure(name: "S", fields: []))])
    }

    @Test("Can be used as variable type")
    func variable_declaration() async throws {
        _ = try parse("data S {} let x: S")
    }

    @Test
    func single_field() async throws {
        let ast = try parse("data S { x: integer }")
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [Variable(
                name: "x",
                semantics: .isolated,
                type: .builtin(.integer),
                initialValue: nil
            )]
        ))])
    }

    @Test
    func multiple_fields() async throws {
        let ast = try parse("data S { x: integer, y: bitfield }")
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [
                Variable(name: "x", semantics: .isolated, type: .builtin(.integer), initialValue: nil),
                Variable(name: "y", semantics: .isolated, type: .builtin(.bitfield), initialValue: nil),
            ]
        ))])
    }

    @Test
    func multiple_fields_with_newlines() async throws {
        let source = """
            data S {
                x: integer
                y: bitfield
            }
            """
        let ast = try parse(source)
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [
                Variable(
                    name: "x",
                    semantics: .isolated,
                    type: .builtin(.integer)
                ),
                Variable(
                    name: "y",
                    semantics: .isolated,
                    type: .builtin(.bitfield)
                ),
            ]
        ))])
    }

    @Test
    func multiple_fields_with_trailing_commas() async throws {
        let source = """
            data S {
                x: integer,
                y: bitfield,
            }
            """
        let ast = try parse(source)
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [
                Variable(
                    name: "x",
                    semantics: .isolated,
                    type: .builtin(.integer)
                ),
                Variable(
                    name: "y",
                    semantics: .isolated,
                    type: .builtin(.bitfield)
                ),
            ]
        ))])
    }

    @Test
    func multiple_fields_with_oddly_placed_commas() async throws {
        let source = """
            data S {
                x: integer
                ,
                y: bitfield
                ,
            }
            """
        let ast = try parse(source)
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [
                Variable(
                    name: "x",
                    semantics: .isolated,
                    type: .builtin(.integer)
                ),
                Variable(
                    name: "y",
                    semantics: .isolated,
                    type: .builtin(.bitfield)
                ),
            ]
        ))])
    }

    @Test
    func static_field() async throws {
        let ast = try parse("data S { static: let x = 43 }")
        #expect(ast == [.dataStructureDeclaration(DataStructure(
            name: "S",
            fields: [],
            companion: CompanionObject(name: "S_static", fields: [
                Variable(name: "x", semantics: .immutable, type: .builtin(.integer), initialValue: .integer(43)),
            ])
        ))])
    }

    @Test
    func static_field_lookup() async throws {
        let source = """
            data S { static: let answer = 42 }
            let a = S.answer
            """
        let ast = try parse(source)
        guard case .variableDeclaration(let variable) = ast.last else { Issue.record("Expected a variable declaration from \(ast)"); return }
        guard case .memberLookup(.identifier(let identifier, type: let identifierType), member: let member, _) = variable.initialValue else { Issue.record("Expected member-lookup from \(variable.initialValue)"); return }
        guard case .companionObject(let data) = identifierType else { Issue.record("Expected companion-object reference, was: \(identifierType)"); return }
        #expect(variable.type == .builtin(.integer))
        #expect(identifier == "S")
        #expect(data.name == "S_static")
        #expect(member == "answer")
    }

    @Test
    func inline_anonymous_nested_structures() async throws {
        let source = """
        data LogInfo {
            position: { latitude: real, longitude: real }
            velocity: { heading: real, speed: real }
        }
        """

        let ast = try parse(source)
        // Expect three data declarations in IR order after resolution:
        // 1) LogInfo$position
        // 2) LogInfo$velocity
        // 3) LogInfo
        // However, parse() returns resolved statements in the order they were declared at top-level.
        // Our parser synthesizes nested declarations internally; they are registered in Scope during resolution
        // but not emitted as separate top-level declarations. We therefore inspect the top-level LogInfo only
        // and verify its fields are typed to the synthesized nested types.

        #expect(ast.count == 1)
        guard case .dataStructureDeclaration(let logInfo) = ast.first else {
            Issue.record("Expected a data structure declaration")
            return
        }
        #expect(logInfo.name == "LogInfo")
        #expect(logInfo.fields.count == 2)

        let pos = logInfo.fields.first { $0.name == "position" }
        let vel = logInfo.fields.first { $0.name == "velocity" }
        let posTypeName = pos?.type.name
        let velTypeName = vel?.type.name

        #expect(posTypeName == "LogInfo$position")
        #expect(velTypeName == "LogInfo$velocity")

        // Verify nested types were registered and their fields resolved correctly by constructing literals
        // and ensuring field lookup types match.
        // Create a small function that returns position.latitude to force resolution of nested field access.
        let source2 = """
        data LogInfo {
            position: { latitude: real, longitude: real }
        }
        pure getLatitude(pos: LogInfo$position) => pos.latitude
        """
        let ast2 = try parse(source2)
        #expect(ast2.count == 2)
        guard case .functionDeclaration(let fn) = ast2.last else {
            Issue.record("Expected a function declaration")
            return
        }
        #expect(fn.name == "getLatitude")
        #expect(fn.parameters.count == 1)
        #expect(fn.parameters.first?.value.type.name == "LogInfo$position")
        #expect(fn.returnType?.name == "real")
    }
}
