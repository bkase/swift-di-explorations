//
//  Cake.swift
//  di-playground
//
//  Created by Brandon Kase on 5/29/17.
//
//

import Foundation

protocol CakeDataStore {
    func get(key: String) -> String
    func set(key: String, value: String)
}
protocol HasCakeDataStore {
    var dataStore: CakeDataStore { get }
}

protocol CakeProgram: HasCakeDataStore/*, HasCakeOtherDeps */ {
    func main() -> String
}
extension CakeProgram {
    func main() -> String {
		dataStore.set(key: "name", value: "Brandon")
        let name = dataStore.get(key: "name")
        return "Hello \(name)"
    }
}
