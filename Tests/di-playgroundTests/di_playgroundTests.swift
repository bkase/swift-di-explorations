import XCTest
@testable import di_playground

// Reader

class TestReaderDataStore: ReaderDataStore {
    private var data: [String: String]
    init() { data = [:] }
    
    func get(key: String) -> String {
        return data[key]!
    }
    
    func set(key: String, value: String) {
        return data[key] = value
    }
}

// Free

func freeTestInterpret<A>(program: FreeDataStore<A>) -> A {
    func loop(prog: FreeDataStore<A>, data: [String: String]) -> A {
	    switch prog {
        case let .fix(.get(key, next)):
            return loop(prog: next(data[key]!), data: data)
        case let .fix(.set(key, val, next)):
            var d = data
            d[key] = val
            return loop(prog: next, data: d)
        case let .halt(v):
            return v
	    }    
    }
    
    return loop(prog: program, data: [:])
}

// Cake

class TestCakeDataStore: CakeDataStore {
    private var data: [String: String]
    init() { data = [:] }
    
    func get(key: String) -> String {
        return data[key]!
    }
    
    func set(key: String, value: String) {
        return data[key] = value
    }
}
class TestBakedCake: CakeProgram, HasCakeDataStore /* and HasWhatever; Note: we need all of them */ {
    let dataStore: CakeDataStore = TestCakeDataStore()
}

class di_playgroundTests: XCTestCase {
    func testReader() {
        XCTAssertEqual(ReaderProgram.main().run(Config(dataStore: TestReaderDataStore())), "Hello Brandon")
    }
    
    func testFree() {
        XCTAssertEqual(freeTestInterpret(program: FreeProgram.main()), "Hello Brandon")
    }

    func testCake() {
        XCTAssertEqual(TestBakedCake().main(), "Hello Brandon")
    }

    static var allTests = [
        ("testReader", testReader),
        ("testFree", testFree),
        ("testCake", testCake),
    ]
}
