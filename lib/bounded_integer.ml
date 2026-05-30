(** Bounded integer library - Implementation *)

exception Out_of_bounds

include Bounded_integer_types

(** The functor implementation. 
    
    See the interface ({!module:Bounded_integer}) for documentation.
    
    Overflow/underflow checks are conditionally included based on compile-time
    analysis of the bounds. If the bounds are sufficiently small that overflow
    is impossible, the checks are omitted.
    
    For addition and subtraction, we use efficient bitwise checks:
    - Addition: [(a bit_xor result) bit_and (b bit_xor result) < 0]
    - Subtraction: [(a bit_xor b) bit_and (a bit_xor result) < 0]
    
    These detect overflow in two's complement arithmetic with just 2 bitwise ops and 1 compare.
    
    Note: The subtraction overflow condition is conservative (always checked) because
    computing the range [lower, upper] can itself overflow.
*)
module BoundedInteger (P : BOUNDED_INTEGER_PARAMS) : BOUNDED_INTEGER_RESULT = struct
  open P.Type
  type t = P.Type.t

  let min_value = P.lower
  let max_value = P.upper
  let zero = P.Type.of_int 0
  let two = P.Type.of_int 2

  (* Compute at functor application time whether overflow checks are needed.
     Since these are computed from the functor parameters, they become constants
     in the resulting module, allowing the compiler to optimize away dead branches. *)

  (* Let a <= b the technical bounds, and A <= B the logical bounds:
     - a = P.Type.min_value
     - b = P.Type.max_value
     - A = P.lower
     - B = P.upper.

     Let x, y be numbers in the logical range.
     Following must be true: a <= A <= x, y <= B <= b. 

     For technical reasons, we assume a <= 0 <= b.
          
     (+) cannot overflow if
     - a <= 2A and
     - 2B <= b.
     Proof:
     - x + y >= 2A >= a
     - x + y <= 2B <= b

     As 2A and 2B can over/underflow in Ocaml at compile time, the conditions
     are formed to
     - a/2 <= A and
     - B <= b/2.
     Because a <= 0, integer division a/2 rounds towards zero, thus is greater
     than the exact division, strengthening the condition a/2 <= A.
     Similarly, b/2 also rounds towards zero because b >= 0.

     (-) cannot overflow if 
     - B - A <= b and
     - A - B >= a
     Proof:
     - x - y >= A - B >= a
     - x - y <= B - A <= b

     The problem in Ocaml is that the compile time calculation itself can 
     over/underflow.

  *)
  
  (* For addition: overflow possible if 2*upper > max_value or 2*lower < min_value *)
  let half_max = P.Type.max_value / two
  let half_min = P.Type.min_value / two
  let check_add_overflow =
    P.Type.compare P.upper half_max > 0 || P.Type.compare P.lower half_min < 0

  (* For subtraction: always check (conservative, as range computation can overflow) *)
  let check_sub_overflow = true

  (* For multiplication: always check (conservative) *)
  let check_mul_overflow = true

  (* For negation: overflow only possible if lower = min_value *)
  let check_neg_overflow = P.Type.compare P.lower P.Type.min_value = 0

  (** Check if a value is within the user-specified bounds [P.lower, P.upper]. *)
  let check_bounds x =
    if P.Type.compare x P.lower < 0 || P.Type.compare x P.upper > 0 then
      raise Out_of_bounds

  let of_int n =
    let result = P.Type.of_int n in
    check_bounds result;
    result

  let add a b =
    let result = a + b in
    if check_add_overflow then begin
      (* Efficient overflow check using bitwise operations.
         For signed integers in two's complement: overflow occurs iff
         (a bit_xor result) bit_and (b bit_xor result) has the sign bit set (i.e., < 0),
         which detects when a and b have the same sign but result has a different sign. *)
      if P.Type.bit_and (P.Type.bit_xor a result) (P.Type.bit_xor b result) < zero then
        raise Out_of_bounds
    end;
    check_bounds result;
    result

  let sub a b =
    let result = a - b in
    if check_sub_overflow then begin
      (* Efficient overflow check using bitwise operations.
         For signed integers in two's complement: overflow occurs iff
         (a bit_xor b) bit_and (a bit_xor result) has the sign bit set (i.e., < 0).
         This detects when the operands have different signs but the result
         has an inconsistent sign (indicating wrap-around). *)
      if P.Type.bit_and (P.Type.bit_xor a b) (P.Type.bit_xor a result) < zero then
        raise Out_of_bounds
    end;
    check_bounds result;
    result

  let mul a b =
    let result = a * b in
    if check_mul_overflow then begin
      (* Overflow check for multiplication using sign analysis.
         For two's complement: if a and b have the same sign (both positive or both negative)
         but the result has a different sign, overflow occurred. *)
      let a_neg = P.Type.compare a zero < 0 in
      let b_neg = P.Type.compare b zero < 0 in
      let result_neg = P.Type.compare result zero < 0 in
      let signs_match = (a_neg && b_neg && not result_neg) || 
                        (a_neg && not b_neg && result_neg) ||
                        (not a_neg && b_neg && result_neg) ||
                        (not a_neg && not b_neg && not result_neg) in
      if not signs_match && P.Type.compare result zero <> 0 then raise Out_of_bounds
    end;
    check_bounds result;
    result

  let div a b =
    let result = a / b in
    check_bounds result;
    result

  let rem a b =
    let result = a - (a / b) * b in
    check_bounds result;
    result

  let neg a =
    let result = ~- a in
    if check_neg_overflow then begin
      (* Negation: if a is min_value, then -a would overflow in two's complement *)
      if P.Type.compare a P.Type.min_value = 0 && P.Type.compare result zero <> 0 then
        raise Out_of_bounds
    end;
    check_bounds result;
    result

  let abs a =
    if P.Type.compare a zero < 0 then begin
      let result = ~- a in
      if check_neg_overflow then begin
        if P.Type.compare a P.Type.min_value = 0 && P.Type.compare result zero <> 0 then
          raise Out_of_bounds
      end;
      check_bounds result;
      result
    end else begin
      check_bounds a;
      a
    end

  let ( + ) = add
  let ( - ) = sub
  let ( * ) = mul
  let ( / ) = div
  let ( ~- ) = neg
  let compare = P.Type.compare
end
