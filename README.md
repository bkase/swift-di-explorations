# Functional DI Solutions in Swift

Our code has dependencies. We would like to not bake in dependencies to side-effecting singleton-esque services because our code becomes harder to reason about, harder to test, etc.

Dependency injection is about decoupling your code from your effects. In traditional OO languages, it's tough to get a compile-time-checked type-safe DI solution working, but Swift is functional(ish).

This repository explores the "functional" solutions to DI that are used in other functional languages (Scala, Haskell, etc)

