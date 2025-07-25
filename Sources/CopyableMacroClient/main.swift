import CopyableMacro

@Copyable
final class Sample {
    var x: Int
    let y: Double

    init(x: Int, y: Double) {
        self.x = x
        self.y = y
    }
}

let sample = Sample(x: 1, y: 2)
print(String(describing: sample))

@Copyable
struct StructSample {
    var firstProp: Bool = false
    let secondProp: String
    let t: String?
    var fourth: String {
        secondProp
    }
    let fifth: [Int]
    
    init(firstProp: Bool, secondProp: String, t: String?, fifth: [Int]) {
        self.firstProp = firstProp
        self.secondProp = secondProp
        self.t = t
        self.fifth = fifth
    }
}

let structSample = StructSample(
    firstProp: true,
    secondProp: "secondProp",
    t: "Ugo",
    fifth: [0, 1]
)

print(String(describing: structSample))

let structNilSetToNil = structSample.copy(t: nil)
print(String(describing: structNilSetToNil))

let structNilSetToNilMamazy = structSample.copy(secondProp: "new", t: "Mamazy")
print(String(describing: structNilSetToNilMamazy))
