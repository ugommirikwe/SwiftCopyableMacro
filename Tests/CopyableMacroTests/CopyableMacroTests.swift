import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CopyableMacroMacros)
import CopyableMacroMacros

let testMacros: [String: Macro.Type] = [
    "Copyable": CopyableMacroMacro.self,
]
#endif

final class CopyableMacroTests: XCTestCase {
//    func testMacro() throws {
//        #if canImport(CopyableMacroMacros)
//        assertMacroExpansion(
//            """
//            #stringify(a + b)
//            """,
//            expandedSource: """
//            (a + b, "a + b")
//            """,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
    
    func testMacroForClass() {
        assertMacroExpansion(
            """
            @Copyable
            class Sample {
                var x: Int
                let y: Double
            
                var myComputedProperty: String {
                    "hello world"
                }
            
                private var _something: Bool
            
                var something: Bool {
                    get {
                        return _something
                    }
                    set {
                        _something = newValue
                    }
                }
            
                func sayHi() {
            
                }
            
                func sayBye() { }
            }
            """,
            expandedSource:
            """
            
            class Sample {
                var x: Int
                let y: Double
            
                var myComputedProperty: String {
                    "hello world"
                }
            
                private var _something: Bool
            
                var something: Bool {
                    get {
                        return _something
                    }
                    set {
                        _something = newValue
                    }
                }
            
                func sayHi() {
            
                }
            
                func sayBye() { }
            }
            """,
            macros: testMacros
        )
    }
    
    func testMacroForStruct() {
        assertMacroExpansion(
            """
            struct User {
                let name: String
                let followers: [String]
            }
            
            @Copyable
            struct Sample {
                var x: Int
                let y: Double
                var g: String? = nil
                let users: [User]
            
                var myComputedProperty: String {
                    "hello world"
                }
            
                private var _something: Bool
            
                var something: Bool {
                    get {
                        return _something
                    }
                    set {
                        _something = newValue
                    }
                }
            
                func sayHi() {
            
                }
            
                func sayBye() { }
            }
            """,
            expandedSource:
            """
            struct User {
                let name: String
                let followers: [String]
            }
            struct Sample {
                var x: Int
                let y: Double
                var g: String? = nil
                let users: [User]
            
                var myComputedProperty: String {
                    "hello world"
                }
            
                private var _something: Bool
            
                var something: Bool {
                    get {
                        return _something
                    }
                    set {
                        _something = newValue
                    }
                }
            
                func sayHi() {
            
                }
            
                func sayBye() { }
            
                public func copy(
                    x: Int? = nil,
                    y: Double? = nil,
                    g: String? = nil,
                    users: [User]? = nil
                ) -> Self {
                    .init(
                        x: x ?? self.x,
                        y: y ?? self.y,
                        g: g ?? self.g,
                        users: users ?? self.users
                    )
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testLazyPropsAreTreatedProperly() {
        assertMacroExpansion(
            """
            @Copyable
            class Sample {
                lazy var x: Int = 1
                let y: Double
            }
            """,
            expandedSource:
            """
            
            class Sample {
                lazy var x: Int = 1
                let y: Double
            }
            """,
            macros: testMacros
        )
    }
    
    func testLetPropertiesWithValuesAreTreatedCorrectly() {
        assertMacroExpansion(
            """
            @Copyable
            class Sample {
                let y: Double = 0
            }
            """,
            expandedSource:
            """
            
            class Sample {
                let y: Double = 0
            }
            """,
            macros: testMacros
        )
    }
    
    // FIXME: this should treated as a separate edge case
    func testDuplicatedInitsAreNotCreated() {
        assertMacroExpansion(
            """
            @Copyable
            struct Sample {
                public init() {
            
                }
            }
            """,
            expandedSource:
            """
            
            struct Sample {
                public init() {
            
                }
            }
            """,
            macros: testMacros
        )
    }
    
    // FIXME: this should treated as a separate edge case
    func testInitsAreNotCreated() {
        assertMacroExpansion(
            """
            @Copyable
            struct Sample {
            }
            """,
            expandedSource:
            """
            struct Sample {
            }
            """,
            macros: testMacros
        )
    }
}
