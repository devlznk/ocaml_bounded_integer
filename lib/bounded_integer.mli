open Bounded_integer_types

exception Out_of_bounds

include module type of struct
  include Bounded_integer_types
end

module BoundedInteger : functor (P : BOUNDED_INTEGER_PARAMS) -> BOUNDED_INTEGER_RESULT
