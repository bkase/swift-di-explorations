import XCTest
@testable import di_playground

/// Our Reader program needs some concrete class to be the datastore
/// Here we just use a wrapper around a dictionary
class TestReaderDataStore: ReaderDataStore {
    private var data: [String: String]
    init() { data = [:] }
    
    func get(key: String) -> String {
        /// Remember not to use ! in your real apps
        return data[key]!
    }
    
    func set(key: String, value: String) {
        return data[key] = value
    }
}

/// The FreeDataStore is interpreted with a recursive function. There
/// is no need for any class or struct. Moreover, we can interpret the
/// same program in different ways throughout our code.
func freeTestInterpret<A>(program: FreeDataStore<A>) -> A {
    /// Again we just wrap a dictionary
    func loop(prog: FreeDataStore<A>, data: [String: String]) -> A {
	    switch prog {
        case let .fix(.get(key, next)):
            return loop(prog: next(data[key]!), data: data)
        case let .fix(.set(key, val, next)):
            var d = data
            d[key] = val
            return loop(prog: next(), data: d)
        case let .halt(v):
            return v
	    }    
    }
    
    return loop(prog: program, data: [:])
}

/// Our CakeDataStore program also needs some class conforming to the
/// Cake operations we laid out earlier.
class TestCakeDataStore: CakeDataStore {
    private var data: [String: String]
    init() { data = [:] }
    
    func get(key: String) -> String {
        /// Remember not to use ! in your real apps
        return data[key]!
    }
    
    func set(key: String, value: String) {
        return data[key] = value
    }
}
/// The cake pattern also demands that we "bake the cake" somewhere:
/// In other words, we need to conform to the CakeProgram protocol
/// by supplying our concrete implementations of all our depencies.
class TestBakedCake: CakeProgram /* implies HasCakeDataStore */ {
    let dataStore: CakeDataStore = TestCakeDataStore()
    /// We would put all of our dependencies here
}

class di_playgroundTests: XCTestCase {
    func testReader() {
        /// We evaluate programs inside a Reader monad by running them
        /// with some config that provides the dependencies
        XCTAssertEqual(
            ReaderProgram.main().run(Config(dataStore: TestReaderDataStore())),
            "Hello Brandon"
        )
    }
    
    func testFree() {
        /// We evaluate free programs by executing some interpreter
        XCTAssertEqual(
            freeTestInterpret(program: FreeProgram.main()),
            "Hello Brandon"
        )
    }

    func testCake() {
        /// We evaluate baked cakes, by invoking the main method
        /// that we declared in our protocol
        XCTAssertEqual(
            TestBakedCake().main(),
            "Hello Brandon"
        )
    }

    static var allTests = [
        ("testReader", testReader),
        ("testFree", testFree),
        ("testCake", testCake),
    ]
}
