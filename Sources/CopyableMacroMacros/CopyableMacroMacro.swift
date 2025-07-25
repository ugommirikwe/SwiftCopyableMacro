import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `Copyable` macro, adds a `copy` method to a struct type.
public struct CopyableMacroMacro: MemberMacro {
    @main
    struct CopyableMacroPlugin: CompilerPlugin {
        let providingMacros: [Macro.Type] = [
            CopyableMacroMacro.self,
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Extract the properties from the type--must be a struct
        guard let storedProperties = declaration
            .as(StructDeclSyntax.self)?.storedProperties(),
              !storedProperties.isEmpty
        else { return [] }
        
        let funcArguments = storedProperties
            .compactMap { property -> (name: String, type: String)? in
                guard
                    // Get the property's name (a.k.a. identifier)...
                    let patternBinding = property.bindings.first?.as(
                        PatternBindingSyntax.self
                    ),
                    
                    let name = patternBinding.pattern.as(
                        IdentifierPatternSyntax.self
                    )?.identifier,
                    
                        // ...and then the property's type...
                    let type = patternBinding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.trimmed.description.replacingOccurrences(of: "?", with: "")
                else { return nil }
                
                return (name: name.text, type: type)
            }
        
        let optionalNames: Set<String> = Set(
            storedProperties.compactMap { property in
                guard
                    let binding = property.bindings.first,
                    let id = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
                    binding.typeAnnotation?.type.as(OptionalTypeSyntax.self) != nil
                else {
                    return nil
                }
                return id.text
            }
        )
        
        let funcBody: ExprSyntax = """
        .init(
        \(raw: funcArguments.map {arg in
            if optionalNames.contains(arg.name) {
              // Explicit nil assignment preserved
              return "\(arg.name): \(arg.name)"
            } else {
              return "\(arg.name): \(arg.name) ?? self.\(arg.name)"
            }
        }.joined(separator: ", \n"))
        )
        """
        
        guard
            let funcDeclSyntax = try? FunctionDeclSyntax(
                SyntaxNodeString(
                    stringLiteral: """
                    public func copy(
                    \(funcArguments.map { "\($0.name)\($0.type)? = nil" }.joined(separator: ", \n"))
                    ) -> Self
                    """.trimmingCharacters(in: .whitespacesAndNewlines)
                ),
                bodyBuilder: {
                    funcBody
                }
            ),
            let finalDeclaration = DeclSyntax(funcDeclSyntax)
        else {
            return []
        }
        
        return [finalDeclaration]
    }
    
    
}

extension VariableDeclSyntax {
    /// Check this variable is a stored property
    var isStoredProperty: Bool {
        guard let binding = bindings.first,
              bindings.count == 1,
              modifiers.contains(where: {
                  $0.name == .keyword(.public)
              }) || modifiers.isEmpty
        else { return false }
        
        switch binding.accessorBlock?.accessors {
        case .none:
            return true
            
        case .accessors(let node):
            for accessor in node {
                switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    // stored properties can have observers
                    break
                default:
                    // everything else makes it a computed property
                    return false
                }
            }
            return true
            
        case .getter:
            return false
        }
    }
}

extension DeclGroupSyntax {
    /// Get the stored properties from the declaration based on syntax.
    func storedProperties() -> [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  variable.isStoredProperty 
            else { return nil }
            
            return variable
        }
    }
}
