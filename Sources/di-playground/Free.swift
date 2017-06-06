//
//  Free.swift
//  di-playground
//
//  Created by Brandon Kase on 5/29/17.
//
//

/// One way to factor a dependency out of some computation is to reify the
/// the computation into a data-structure and interpret the computation with
/// the dependency later. A computation is a collection of commands
/// that are weaved together with "Free" -- the monad freely generated
/// by any command functor.

/// We can represent our data store as a series of commands with a callback
/// when the command is done that tells us what to do next.
///
/// The value we produce we can store in the type-variable Recur.
indirect enum DataStoreCommands<Recur> {
    /// Get produces a String so that appears in the input of our next callback
    case get(key: String, next: (String) -> Recur)
    /// Set doesn't give us any information other than telling us that we're done
    /// so we use () to represent that in our input
    case set(key: String, value: String, next: () -> Recur)
}

extension DataStoreCommands /* Functor */ {
    /// We can map over our result after every command
    func map<B>(_ f: @escaping (Recur) -> B) -> DataStoreCommands<B> {
        switch self {
        case let .get(key, next): return .get(key: key, next: { s in f(next(s)) })
        case let .set(key, value, next): return .set(key: key, value: value, next: { () in f(next()) })
        }
    }
}

/// Unfortunately, making programs from our DataStoreCommands directly is a little
/// annoying because the type grows for every command we issue:
/// For example, if we get and then set and then get and return the value, our type 
/// would be DataStoreCommands<DataStoreCommands<DataStoreCommands<String>>>

/// Now we want some substrate upon which we can construct some sort of program
/// data-structure from the commands. What we need is a way to stop with a value
/// and a way to keep going after a command, such that we don't have to think about a 
/// nested type.
///
/// Let's call stop "halt", and keep going "fix".
///
/// Aside: In a language that does support Higher-Kinded-Types we could build
/// this data- structure abstracted over any set of commands built in this way.
/// Commands just needs to be a functor (and with the Coyoneda-trick we don't
/// even need the functor constraint).
indirect enum FreeDataStore<A> {
    /// Produce a value A
    case halt(A)
    /// Perform another command in our program
    case fix(DataStoreCommands<FreeDataStore<A>>)
}

extension FreeDataStore /* Functor */ {
    /// We can thread our transformation through our commands
    /// until we halt
    func map<B>(_ f: @escaping (A) -> B) -> FreeDataStore<B> {
        switch self {
        case let .fix(.get(key, next)): return .fix(.get(key: key, next: { s in next(s).map(f) }))
        case let .fix(.set(key, value, next)): return .fix(.set(key: key, value: value, next: { () in next().map(f) }))
        case let .halt(v): return .halt(f(v))
        }
    }
}

extension FreeDataStore /* Monad */ {
    /// We can lift a value into a program that just
    /// halts with that value
    static func pure(_ v: A) -> FreeDataStore<A> {
        return FreeDataStore<A>.halt(v)
    }
    
    /// We can thread through f in the same way as map -- we just
    /// don't need to wrap our result back in a halt
    ///
    /// Flatmap here lets us change our program at runtime based on
    /// some intermediate result
    func flatMap<B>(_ f: @escaping (A) -> FreeDataStore<B>) -> FreeDataStore<B> {
        switch self {
        case let .fix(.get(key, next)): return .fix(.get(key: key, next: { s in next(s).flatMap(f) }))
        case let .fix(.set(key, value, next)): return .fix(.set(key: key, value: value, next: { () in next().flatMap(f) }))
        case let .halt(v): return f(v)
        }
    }
}

/// Our domain-specific-language or DSL here is a collection 
/// of static methods that wrap up our commands in fix with
/// continuations that just halt with the result
enum FreeDataStoreDsl {
    static func get(key: String) -> FreeDataStore<String> {
        return .fix(.get(key: key, next: { s in .halt(s) }))
    }
    
    static func set(key: String, value: String) -> FreeDataStore<()> {
        return .fix(.set(key: key, value: value, next: { () in .halt(()) }))
    }
}

/// Our program that uses our DSL is actually a data-structure
/// Invoking main gives us a data-structure that we can interpret with
/// our dependency later.
///
/// Interestingly, we can optimize our program since we can view it
/// as a datastructure. For example, in this case we could annihilate
/// the set and the get before evaluating it.
enum FreeProgram {
    static func main() -> FreeDataStore<String> {
        return FreeDataStoreDsl.set(key: "name", value: "Brandon").flatMap{ _ in
            FreeDataStoreDsl.get(key: "name")
        }.map{ name in "Hello \(name)" }
    }
}

