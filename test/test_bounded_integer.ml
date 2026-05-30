open Bounded_integer

module Bounded5 = BoundedInteger (struct
    module Type = Base.Int
    let lower = Base.Int.of_int 0
    let upper = Base.Int.of_int 5
  end)

(* Test with full range to test overflow detection *)
module FullRange = BoundedInteger (struct
    module Type = Base.Int
    let lower = Base.Int.min_value
    let upper = Base.Int.max_value
  end)

let test_of_int_within_bounds () =
  let x = Bounded5.of_int 3 in
  Bounded5.compare x (Bounded5.of_int 3) = 0

let test_of_int_at_lower_bound () =
  let x = Bounded5.of_int 0 in
  Bounded5.compare x Bounded5.min_value = 0

let test_of_int_at_upper_bound () =
  let x = Bounded5.of_int 5 in
  Bounded5.compare x Bounded5.max_value = 0

let test_of_int_below_lower_bound_raises () =
  try
    let _ = Bounded5.of_int (-1) in
    false
  with Out_of_bounds -> true

let test_of_int_above_upper_bound_raises () =
  try
    let _ = Bounded5.of_int 6 in
    false
  with Out_of_bounds -> true

let test_add_within_bounds () =
  let x = Bounded5.of_int 2 in
  let y = Bounded5.of_int 3 in
  Bounded5.compare (Bounded5.add x y) (Bounded5.of_int 5) = 0

let test_add_above_upper_bound_raises () =
  try
    let x = Bounded5.of_int 3 in
    let y = Bounded5.of_int 3 in
    let _ = Bounded5.add x y in
    false
  with Out_of_bounds -> true

let test_sub_within_bounds () =
  let x = Bounded5.of_int 5 in
  let y = Bounded5.of_int 2 in
  Bounded5.compare (Bounded5.sub x y) (Bounded5.of_int 3) = 0

let test_sub_below_lower_bound_raises () =
  try
    let x = Bounded5.of_int 2 in
    let y = Bounded5.of_int 3 in
    let _ = Bounded5.sub x y in
    false
  with Out_of_bounds -> true

let test_mul_within_bounds () =
  let x = Bounded5.of_int 2 in
  let y = Bounded5.of_int 2 in
  Bounded5.compare (Bounded5.mul x y) (Bounded5.of_int 4) = 0

let test_mul_above_upper_bound_raises () =
  try
    let x = Bounded5.of_int 2 in
    let y = Bounded5.of_int 3 in
    let _ = Bounded5.mul x y in
    false
  with Out_of_bounds -> true

let test_neg_within_bounds () =
  let x = Bounded5.of_int 0 in
  Bounded5.compare (Bounded5.neg x) (Bounded5.of_int 0) = 0

let test_neg_below_lower_bound_raises () =
  try
    let x = Bounded5.of_int 1 in
    let _ = Bounded5.neg x in
    false
  with Out_of_bounds -> true

let test_operator_add () =
  let x = Bounded5.of_int 2 in
  let y = Bounded5.of_int 3 in
  Bounded5.compare (Bounded5.( + ) x y) (Bounded5.of_int 5) = 0

let test_operator_sub () =
  let x = Bounded5.of_int 5 in
  let y = Bounded5.of_int 2 in
  Bounded5.compare (Bounded5.( - ) x y) (Bounded5.of_int 3) = 0

let test_operator_mul () =
  let x = Bounded5.of_int 2 in
  let y = Bounded5.of_int 2 in
  Bounded5.compare (Bounded5.( * ) x y) (Bounded5.of_int 4) = 0

let test_min_value () =
  Bounded5.compare Bounded5.min_value (Bounded5.of_int 0) = 0

let test_max_value () =
  Bounded5.compare Bounded5.max_value (Bounded5.of_int 5) = 0

(* Overflow detection tests with full range *)

let test_overflow_add_max () =
  (* With full range, max_value + 1 should wrap and be detected as overflow *)
  try
    let x = FullRange.of_int (Base.Int.to_int Base.Int.max_value) in
    let _ = FullRange.add x (FullRange.of_int 1) in
    false
  with Out_of_bounds -> true

let test_overflow_add_min () =
  (* min_value + (-1) should underflow *)
  try
    let x = FullRange.of_int (Base.Int.to_int Base.Int.min_value) in
    let _ = FullRange.add x (FullRange.of_int (-1)) in
    false
  with Out_of_bounds -> true

let test_overflow_mul () =
  (* max_value / 2 + 1 multiplied by 2 should overflow *)
  try
    let x = FullRange.of_int (Base.Int.to_int Base.Int.max_value / 2 + 1) in
    let _ = FullRange.mul x (FullRange.of_int 2) in
    false
  with Out_of_bounds -> true

let test_overflow_neg_min () =
  (* negating min_value should overflow *)
  try
    let x = FullRange.of_int (Base.Int.to_int Base.Int.min_value) in
    let _ = FullRange.neg x in
    false
  with Out_of_bounds -> true

let () =
  let tests = [
    ("of_int within bounds", test_of_int_within_bounds);
    ("of_int at lower bound", test_of_int_at_lower_bound);
    ("of_int at upper bound", test_of_int_at_upper_bound);
    ("of_int below lower bound raises", test_of_int_below_lower_bound_raises);
    ("of_int above upper bound raises", test_of_int_above_upper_bound_raises);
    ("add within bounds", test_add_within_bounds);
    ("add above upper bound raises", test_add_above_upper_bound_raises);
    ("sub within bounds", test_sub_within_bounds);
    ("sub below lower bound raises", test_sub_below_lower_bound_raises);
    ("mul within bounds", test_mul_within_bounds);
    ("mul above upper bound raises", test_mul_above_upper_bound_raises);
    ("neg within bounds", test_neg_within_bounds);
    ("neg below lower bound raises", test_neg_below_lower_bound_raises);
    ("operator add", test_operator_add);
    ("operator sub", test_operator_sub);
    ("operator mul", test_operator_mul);
    ("min_value", test_min_value);
    ("max_value", test_max_value);
    ("overflow add max", test_overflow_add_max);
    ("overflow add min", test_overflow_add_min);
    ("overflow mul", test_overflow_mul);
    ("overflow neg min", test_overflow_neg_min);
  ] in
  Stdlib.List.iter (fun (name, test) ->
    if test () then
      Printf.printf "PASS: %s\n" name
    else
      Printf.printf "FAIL: %s\n" name) tests
