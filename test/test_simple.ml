open Bounded_integer

module Bounded5 = BoundedInteger(struct
  module Type = Base.Int
  let lower = Base.Int.of_int 0
  let upper = Base.Int.of_int 5
end)

let () = Printf.printf "Success!\n"
