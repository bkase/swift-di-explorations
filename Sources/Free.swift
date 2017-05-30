//
//  Free.swift
//  di-playground
//
//  Created by Brandon Kase on 5/29/17.
//
//

import Foundation

// Swift can't abstract out Free from the type
// this is both the datatype and the dsl

indirect enum FreeDataStoreCommands<A, Recur> {
    case get(key: String, next: (String) -> Recur)
    case set(key: String, value: String, next: Recur)
}
indirect enum FreeDataStore<A> {
    case halt(A)
    case fix(FreeDataStoreCommands<A, FreeDataStore<A>>)
}

extension FreeDataStore /* Functor */ {
    func map<B>(_ f: @escaping (A) -> B) -> FreeDataStore<B> {
        switch self {
        case let .fix(.get(key, next)): return .fix(.get(key: key, next: { s in next(s).map(f) }))
        case let .fix(.set(key, value, next)): return .fix(.set(key: key, value: value, next: next.map(f)))
        case let .halt(v): return .halt(f(v))
        }
    }
}

extension FreeDataStore /* Monad */ {
    static func pure(_ v: A) -> FreeDataStore<A> {
        return FreeDataStore<A>.halt(v)
    }
    
    func flatMap<B>(_ f: @escaping (A) -> FreeDataStore<B>) -> FreeDataStore<B> {
        switch self {
        case let .fix(.get(key, next)): return .fix(.get(key: key, next: { s in next(s).flatMap(f) }))
        case let .fix(.set(key, value, next)): return .fix(.set(key: key, value: value, next: next.flatMap(f)))
        case let .halt(v): return f(v)
        }
    }
}

// DSL to make it so we don't have to fix

enum FreeDataStoreDsl {
    static func get(key: String) -> FreeDataStore<String> {
	    return .fix(.get(key: key, next: { s in .halt(s) }))
    }
    
	static func set(key: String, value: String) -> FreeDataStore<()> {
        return .fix(.set(key: key, value: value, next: .halt()))
    }
}

// Program using DSL

enum FreeProgram {
    static func main() -> FreeDataStore<String> {
        return FreeDataStoreDsl.set(key: "name", value: "Brandon").flatMap{ () in
            FreeDataStoreDsl.get(key: "name")
        }.map{ name in "Hello \(name)" }
    }
}

