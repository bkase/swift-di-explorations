
// Reader

struct Reader<In, Data> {
    let run: (In) -> Data
    
    var ask: Reader<In, In> {
	   return Reader<In, In> { i in i }
    }
}

extension Reader /* Functor */ {
    func map<B>(_ f: @escaping (Data) -> B) -> Reader<In, B> {
        return Reader<In, B> { i in f(self.run(i)) }
    }
}

extension Reader /* Monad */ {
    static func pure(a: Data) -> Reader<In, Data> {
        return Reader<In, Data> { _ in a }
    }
    
    func flatMap<B>(_ f: @escaping (Data) -> Reader<In, B>) -> Reader<In, B> {
        return Reader<In, B> { i in f(self.run(i)).run(i) }
    }
}

// Abstract Datastore

struct Config {
    let dataStore: ReaderDataStore
    /* and whatever else we need */
}
protocol ReaderDataStore {
    func get(key: String) -> String
    func set(key: String, value: String)
}
enum ReaderDataStoreDsl {
    static func get(key: String) -> Reader<Config, String> {
        return Reader<Config, String> { c in c.dataStore.get(key: key) }
    }
    
    static func set(key: String, value: String) -> Reader<Config, ()> {
        return Reader<Config, ()> { c in c.dataStore.set(key: key, value: value) }
    }
}

// Program using DSL and config

enum ReaderProgram {
    static func main() -> Reader<Config, String> {
        return ReaderDataStoreDsl.set(key: "name", value: "Brandon").flatMap { () in
            ReaderDataStoreDsl.get(key: "name")
        }.map{ name in "Hello \(name)" }
    }
}
