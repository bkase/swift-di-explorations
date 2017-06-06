//
//  Cake.swift
//  di-playground
//
//  Created by Brandon Kase on 5/29/17.
//
//

/// A dependency is just an interface that declares a bunch
/// of methods, right? In the Cake pattern, we have protocols
/// (aka interfaces in Swift) all the way down.

/// Our datastore has the capabilities to get and set
protocol CakeDataStore {
    func get(key: String) -> String
    func set(key: String, value: String)
}
/// A class may carry a concrete datastore
protocol HasCakeDataStore {
    var dataStore: CakeDataStore { get }
}

/// In the cake pattern, even our program is a protocol.
/// This way, we can assert that we have some concrete datastore
/// without actually providing it.
protocol CakeProgram: HasCakeDataStore/*, HasCakeOtherDeps */ {
    func main() -> String
}
/// The implementation of our CakeProgram is just an extension on
/// the protocol. Here, our program can use all of our dependencies
/// (like our CakeDataStore) that we have asserted through the
/// HasCakeDataStore assertions we made through protocol inheritance.
extension CakeProgram {
    func main() -> String {
        /// In real life, the data-store commands would probably be
        /// under some monad (like a future), so this program would
        /// still be covered in flatMaps like the other examples
		dataStore.set(key: "name", value: "Brandon")
        let name = dataStore.get(key: "name")
        return "Hello \(name)"
    }
}
