# Bounded Integer Library

A functor-based OCaml library for creating type-safe bounded integer types with
compile-time optimized range checking on all arithmetic operations.

## Overview

This library provides a `BoundedInteger` functor that takes:
- An integer type module (e.g., `Base.Int`, `Base.Int63`)
- Lower and upper bounds (inclusive)

And returns a new module with bound-safe arithmetic operations that:
1. Check for low-level overflow/underflow of the underlying integer type
2. Check that results are within the specified bounds
3. Raise `Out_of_bounds` exception on violation

## Features

- **Type Safety**: All operations maintain bounds invariants
- **Efficient Overflow Detection**: Uses bitwise operations for fast overflow checks
- **Compile-Time Optimization**: Unnecessary checks are eliminated by the compiler as far as possible
- **Simple Syntax**: Clean module creation with minimal boilerplate

## Usage

```ocaml
open Bounded_integer

(* Create a bounded integer type for range 0..5 *)
module Bounded5 = BoundedInteger (struct
  module Type = Base.Int
  let lower = Base.Int.of_int 0
  let upper = Base.Int.of_int 5
end)

(* Use it like a regular integer module *)
let x = Bounded5.of_int 3
let y = Bounded5.of_int 4
let z = Bounded5.add x y  (* z = 7, but this raises Out_of_bounds! *)
```

## Example: Temperature Range

```ocaml
module Celsius = BoundedInteger (struct
  module Type = Base.Int
  let lower = Base.Int.of_int (-273)  (* Absolute zero *)
  let upper = Base.Int.of_int 1000   (* Arbitrary upper limit *)
end)

let boiling = Celsius.of_int 100
let freezing = Celsius.of_int 0
let diff = Celsius.sub boiling freezing  (* 100 *)
```

## Implementation Details

### Overflow Detection

The library uses efficient bitwise checks for overflow detection:

- **Addition**: `(a bit_xor result) bit_and (b bit_xor result) < 0`
- **Subtraction**: `(a bit_xor b) bit_and (a bit_xor result) < 0`
- **Multiplication**: Sign analysis comparing operand and result signs

These checks use only 2 bitwise operations and 1 comparison.

### Compile-Time Optimization

Overflow checks are conditionally included based on the specified bounds:

```ocaml
(* Computed at functor application time *)
let check_add_overflow =
  P.Type.compare P.upper (P.Type.max_value / two) > 0
```

Since these flags are constants, the OCaml compiler's dead code elimination
removes unnecessary checks entirely when the bounds make overflow impossible.

### Performance Characteristics

| Operation | Checks | Cost |
|-----------|--------|------|
| Addition | Low-level + bounds | ~3 comparisons + bitwise ops |
| Subtraction | Low-level + bounds | ~3 comparisons + bitwise ops |
| Multiplication | Low-level + bounds | ~4 comparisons |
| Division | Bounds only | ~2 comparisons |
| Negation | Low-level + bounds | ~2 comparisons |

When bounds are small (e.g., 0..5), low-level overflow checks are optimized away
for addition.

## API Reference

### Module Types

```ocaml
module type INT_TYPE = sig
  type t
  val min_value : t
  val max_value : t
  val ( + ) : t -> t -> t
  val ( - ) : t -> t -> t
  val ( * ) : t -> t -> t
  val ( / ) : t -> t -> t
  val ( ~- ) : t -> t
  val compare : t -> t -> int
  val of_int : int -> t
  val bit_xor : t -> t -> t
  val bit_and : t -> t -> t
end

module type BOUNDED_INTEGER_PARAMS = sig
  module Type : INT_TYPE
  val lower : Type.t
  val upper : Type.t
end

module type BOUNDED_INTEGER_RESULT = sig
  type t
  val min_value : t
  val max_value : t
  val of_int : int -> t
  val add : t -> t -> t
  val sub : t -> t -> t
  val mul : t -> t -> t
  val div : t -> t -> t
  val rem : t -> t -> t
  val neg : t -> t
  val abs : t -> t
  val ( + ) : t -> t -> t
  val ( - ) : t -> t -> t
  val ( * ) : t -> t -> t
  val ( / ) : t -> t -> t
  val ( ~- ) : t -> t
  val compare : t -> t -> int
end
```

### Functor

```ocaml
module BoundedInteger : functor (P : BOUNDED_INTEGER_PARAMS) -> BOUNDED_INTEGER_RESULT
```

### Exception

```ocaml
exception Out_of_bounds
```

Raised when:
- Creating a value outside the specified bounds
- An arithmetic operation would overflow/underflow the underlying type
- An arithmetic operation result is outside the specified bounds

## Installation

```bash
dune build
```

## Running Tests

```bash
dune runtest
```

## Supported Integer Types

Any module satisfying `INT_TYPE` can be used. Built-in support includes:
- `Base.Int`
- `Base.Int63`

## Limitations

- Division by zero raises `Division_by_zero` (from Base), not `Out_of_bounds`
- The underlying integer type's limitations apply (e.g., fixed bit width)
- Remainder operation uses truncating division semantics

## License

MIT License
