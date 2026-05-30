(** Bounded integer library
    
    This library provides a functor for creating bounded integer types with
    range checking on all arithmetic operations.
    
    The functor takes an integer type module (like {!Base.Int} or {!Base.Int63})
    and lower/upper bounds, and returns a new module with bound-safe operations.
    
    All operations first check for low-level overflow/underflow of the underlying
    integer type, then check that results are within the specified bounds.
    
    Both checks raise [Out_of_bounds] if violated.
*)

exception Out_of_bounds

open Bounded_integer_types

(** The main functor for creating bounded integer modules.
    
    Example usage:
    {[
      module Bounded5 = BoundedInteger (struct
          module Type = Base.Int
          let lower = Base.Int.of_int 0
          let upper = Base.Int.of_int 5
        end)
    ]}
    
    Or with shorthand syntax:
    {[
      module Bounded5 = BoundedInteger (struct
          let Type = Base.Int
          let lower = Base.Int.of_int 0
          let upper = Base.Int.of_int 5
        end)
    ]}
    
    @param P Module with [Type] (integer module), [lower], and [upper] bounds
    @return A bounded integer module with safe arithmetic operations
*)
module BoundedInteger : functor (P : BOUNDED_INTEGER_PARAMS) -> BOUNDED_INTEGER_RESULT
