# Functional DI Solutions in Swift

Our code has dependencies. We would like to not directly invoke code that uses side-effecting singleton-esque services because our code becomes harder to reason about, harder to test, etc. It would be nice to decouple the effects.

Dependency injection is about decoupling your code from your effects. In traditional OO languages, it's tough to get a compile-time-checked type-safe DI solution working, but Swift is functional(ish).

This repository explores the "functional" solutions to DI that are used in other functional languages (Scala, Haskell, etc)

## Understanding the solutions

In this repo, every implemenation must declare a dependency on some datastore that has the capability to get a string key-value pair given a string key, and set arbitrary key-value pairs given a key and a value.

In all cases, we define a simple program that sets a key-value pair, and then gets that key and uses it to say "hello".

The programs are declared here in literate Swift:

* [Cake Pattern](Sources/di-playground/Cake.swift)

[![Cake pattern](img/cake.png)](Sources/di-playground/Cake.swift)

* [Reader Monad](Sources/di-playground/Reader.swift)

[![Reader Monad](img/reader.png)](Sources/di-playground/Reader.swift)

* [Free Monad](Sources/di-playground/Free.swift)

[![Free Monad](img/free.png)](Sources/di-playground/Free.swift)

The programs are then all evaluated in this

* [Test file](Tests/di-playgroundTests/di_playgroundTests.swift)

[![Test file](img/test.png)](Tests/di-playgroundTests/di_playgroundTests.swift)


