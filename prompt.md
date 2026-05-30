The workspace contains an Ocaml library using dune as build system. The library
uses Base as replacement for the Ocaml standard library.

It shall define a functor BoundedInteger with

* Input
  * IntType: A module with integer operations like Base.Int or Base.Int63
  * Bounds: A module with two values lower and upper of type IntType.t.

BoundedInteger shall create a bounded integer module with bound-safe arithmetic 
operations. 
It must be checked that the low-level operation does not overflow
or underflow the bounds given by IntType.t. 
If the low-level operation did not exceed the bounds of IntType.t, it must be
checked that the result is within the bounds given by bounds. The bounds are
inclusive.
If either bounds check failed, an Out_of_bounds exception shall be raised.

The BoundedInteger shall be implemented such a way that a module representing
a bounded integer in range lower .. upper using an integral type like Base.Int
or Base.Int63 can easily be used.
Example: A module representing bounded integer range 0 .. 5 should look like

`module Bounded5 = BoundedInteger(struct let Type = Int63 let lower=0 let upper=5 end)`

The actual syntax may vary but should have a simple structure, i.e. there should
not be much syntactic noise around the parameter values Int63, 0, and 5.
