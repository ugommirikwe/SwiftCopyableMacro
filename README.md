# Overview

`SwiftCopyableMacro` is a very simple Swift macro library that auto-generates a `copy()` function for structs at compile time, which takes all the public properties of the struct as arguments in the function, enabling a runtime ability to elegantly duplicate an instance of the struct and setting new values for any or all these (even immutable) properties at the same time, similar to what [Kotlin's `data class`](https://kotlinlang.org/docs/data-classes.html#copying) offers.

# How To Use It

The only effort required is to mark the structs with a custom `@Copyable` annotation and the structs are automatically injected with a `copy()` method inside. For example:

```swift
@Copyable // <= annotation is used here
struct User {
    let name: String
    let age: Int
    let hobby: String?
}
```

automatically updates the struct at compile time (which happens instantly if editing the file inside of Xcode) as follows:

```swift
struct User {
    let name: String
    let age: Int
    let hobby: String?

    // Notice the arguments for the function 👇
    func copy(
        name: String? = nil, 
        age: Int? = nil, 
        hobby: String? = nil
    ) -> Self {
        .init(
            name: name ?? self.name,
            age: age ?? self.age,
            hobby: hobby
        )
    }
}
```

This struct can now be used at a call site like so:

```swift
let ugo = User(name: "Ugo", age: 30, hobby: "Fishing")
print(ugo) // Ugo(name: "Ugo", age: 30)

let ugoAsJack = ugo.copy(name: "Jack") // <= .copy() is used here
print(ugoAsJack) // Ugo(name: "Jack", age: 30, hobby: "Fishing")

let ugoIsOlder = ugo.copy(age: 34, hobby: "Cycling") // <= .copy() is used here
print(ugoIsOlder) // Ugo(name: "Ugo", age: 34, hobby: "Cycling")
print(ugoAsJack) // Ugo(name: "Jack", age: 30, hobby: "Cycling")

let jackIsYoungerWithNoHoppy = ugoAsJack.copy(age: 25, hobby: nil) // <= .copy()
print(jackIsYoungerWithNoHoppy) // Ugo(name: "Jack", age: 25, hobby: nil)
```

Xcode will even offer autocomplete listing all the properties declared in the struct as parameters in this `.copy(...)` function.

# Installation

This macro is available for installation via the Swift Package Manager (SPM) as follows:

## Xcode

1. In Xcode, select the menu: `File` → `Add Package Dependencies…` to launch the SPM dialog;
2. in the "Search or Enter Package URL" text field, enter the package URL: https://github.com/ugommirikwe/SwiftCopyableMacro;
3. in "Dependency Rule" select "Branch";
4. in the "Branch" text field enter the value "main"
5. select the project to add the 

## package.swift

For projects that use a `package.swift` file to manage their SPM dependencies, you can add it to your `package.swift` file like so:

```swift
dependencies: [
    .package(url: "https://github.com/ugommirikwe/SwiftCopyableMacro", .branch("main"))
]
```

And then add the product to all targets that use CopyableMacro:

```swift
...
targets: [
    .target(
        name: "<NameOfYourTarget>", 
        dependencies: ["CopyableMacro"],
    )
]
```

# Import & Usage

The [overview](#overview) section above already describes how to use the macro: prepend your struct name with the annotation `@Copyable` and that's all. Xcode 15+ should automatically add the import at the top of the file for you. Otherwise, go ahead and add it as follows to clear any errors in your file:

```swift
import CopyableMacro
```

See the above examples on how to use the macro. Also check out [other examples here](Sources/CopyableMacroClient/main.swift).

# Pre-Release

Please note that this code is still in pre-release stage and should be carefully evaluated before using in your production code.

# ⚠️ Known Limitations & Caveats

1. **Structs Only. No classes or enums**  
      Only plain `struct` types are supported. Applying `@Copyable` to `class` or `enum` types is unsupported and will either do nothing or produce a compile-time diagnostic message.

2. **Custom Initialisers and Default Values**  
   Assigning default values to properties are supported. Similarly defining a custom `init(...)` is supported, but this might cause the `.copy()` generation to fail if the struct's custom initializer does not match the number and order of the properties declared in the struct. If you need to use a custom initializer, ensure it includes all the properties declared in the struct and in the same declaration order.
      
3. **Parameter order matters**  
   Named parameters in `.copy(...)` must follow the struct’s property declaration order to set the properties you'd like to change with the `.copy` function. Unlike in Kotlin, reordering arguments in Swift will result in compile-time errors.

4. **Large structs & runtime performance**  
   .copy() duplicates all stored values, including optional reference types, triggering ARC operations and memory copies. Consider splitting large, complex types into smaller structs. (See: (The cost of large Swift values)[https://github.com/swiftlang/swift/blob/main/docs/OptimizationTips.rst#the-cost-of-large-swift-values]; (SwiftRocks on nested references)[https://swiftrocks.com/memory-management-and-performance-of-value-types]).

5. **Multi‑level Optionals** (e.g., `String??`)  
   Deep optional types may behave unexpectedly. We recommend adding your own tests to validate behavior in those scenarios.

6. **Build-time overhead**  
   As with any macro, using this broadly can impact build times in larger codebases. Profile your builds if you’re applying `@Copyable` to many structs.

# Feedback and Issues

Feel free to submit any issues or suggestions. Pull requests are also welcomed. 

# License

SwiftCopyableMacro is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
