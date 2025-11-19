import Testing
import Parser

@Suite("Scope")
struct ScopeTests {

    @Test
    func resolves_registered_variable_declaration() async throws {
        let scope = Scope()
        let variable = Variable(name: "x", semantics: .immutable, type: .builtin(.bitfield), initialValue: nil)
        scope.register(variable: variable)
        #expect(scope.variable(forName: "x") == variable)
    }

    @Test
    func resolves_variable_declaration_in_parent_scope() async throws {
        let parent = Scope()
        let variable = Variable(name: "x", semantics: .immutable, type: .builtin(.bitfield), initialValue: nil)
        parent.register(variable: variable)

        let scope = Scope(parent: parent, parameters: [])
        #expect(scope.variable(forName: "x") == variable)
    }

    @Test
    func resolves_registered_data_structure_type() async throws {
        let scope = Scope()
        let data = DataStructure(name: "S", fields: [])
        scope.register(type: data)
        #expect(scope.type(forName: "S") == .data(data))
    }

    @Test
    func resolves_data_structure_types_in_parent_scope() async throws {
        let parent = Scope()
        let data = DataStructure(name: "S", fields: [])
        parent.register(type: data)

        let scope = Scope(parent: parent, parameters: [])
        #expect(scope.type(forName: "S") == .data(data))
    }
}
