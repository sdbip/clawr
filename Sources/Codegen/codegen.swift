public func codegen(ir: [Statement]) -> String {
    return """
        #include "oo-stdlib.h"
        #include "oo-runtime.h"

        \(
            ir.map(codegen(statement:))
                .joined(separator: "\n")
        )
        """
}

public func codegen(statement: Statement) -> String {
    switch statement {
    case .data(name: let name, fields: let fields):
        return """
            struct __\(name)_data { \( fields.map { "\($0.type) \($0.name);" }.joined()) };
            typedef struct \(name) {
                struct __oo_rc_header header;
                struct __\(name)_data \(name)Data;
            } \(name);
            """
    case .traitDeclaration(name: let name, methods: let methods):
        return """
            typedef struct \(name)_vtable {
                \(methods.map {
                    "\($0.returnType) (*\($0.name))(\($0.parameters.map { "\($0.type) \($0.name)" }.joined(separator: ", ")));"
                }.joined(separator: "\n    "))
            } \(name)_vtable;
            static const __oo_trait_descriptor \(name)_trait = { .name = "\(name)" };
            """
    case .traitConformances(target: let target, traits: let traits):
        return """
            \(traits.map { """
                \($0.name)_vtable \(target)_\($0.name)_vtable = {
                    \($0.methods.map {
                        ".\($0) = \(target)_\($0)"
                    }.joined(separator: "\n    "))
                };
                """ }.joined(separator: "\n"))

            __oo_data_type __\(target)_data_type = {
                .size = sizeof(\(target)),
                .trait_descs = (__oo_trait_descriptor*[]) { \( traits.map { "&\($0.name)_trait" }.joined(separator: ", ") ) },
                .trait_vtables = (void*[]) { \( traits.map { "&\(target)_\($0.name)_vtable" }.joined(separator: ", ") ) },
                .trait_count = 1
            };
            __oo_type_info __\(target)_info = { .data = &__\(target)_data_type };
            """
    case .variable(let name, type: let type, initializer: let initializer):
        return "\(type) \(name) = \(codegen(expression: initializer));"
    case .assign(let reference, value: let value):
        return "\(codegen(expression: .reference(reference))) = \(codegen(expression: value));"
    case .function(let name, returns: let type, parameters: let parameters, body: let body):
        return """
            \(type) \(name) (\(parameters.map { "\($0.type) \($0.name)" }.joined(separator: ", "))) {
                \(body.map(codegen(statement:)).joined(separator: "\n"))
            }
            """
    case .call(let reference, arguments: let arguments):
        return "\(codegen(expression: .reference(reference)))(\(arguments.map(codegen(expression:)).joined(separator: ",")));"
    case .return(let expr):
        return "return \(codegen(expression: expr));"
    }
}

func codegen(expression: Expression) -> String {
    switch expression {
    case .literal(let s): return s
    case .reference(.cast(let reference, type: let type)):
        return "(\(type))\(codegen(expression: .reference(reference)))"
    case .reference(.name(let name)):
        return "\(name)"
    case .reference(.field(target: let reference, name: let name, isPointer: let isPointer)):
        return "(\(codegen(expression: .reference(reference))))\(isPointer ? "->" : ".")\(name)"
    case .call(let reference, arguments: let arguments):
        return "\(codegen(expression: .reference(reference)))(\(arguments.map(codegen(expression:)).joined(separator: ",")))"
    }
}
