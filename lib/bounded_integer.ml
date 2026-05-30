(** Bounded integer library - Implementation *)

exception Out_of_bounds

include Bounded_integer_types

(** The functor implementation. 
    
    See the interface ({!module:Bounded_integer}) for documentation.
    
    Overflow/underflow checks are inlined in each operation to allow
    the compiler to optimize them away when the bounds make overflow impossible.
*)
module BoundedInteger (P : BOUNDED_INTEGER_PARAMS) : BOUNDED_INTEGER_RESULT = struct
  open P.Type
  type t = P.Type.t

  let min_value = P.lower
  let max_value = P.upper
  let zero = P.Type.of_int 0

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
    (* Inlined overflow check for addition *)
    let a_nonneg = P.Type.compare a zero >= 0 in
    let b_nonneg = P.Type.compare b zero >= 0 in
    let result_neg = P.Type.compare result zero < 0 in
    (* If both operands are non-negative but result is negative, we overflowed *)
    if a_nonneg && b_nonneg && result_neg then raise Out_of_bounds;
    (* If both operands are negative but result is non-negative, we underflowed *)
    if not a_nonneg && not b_nonneg && not result_neg then raise Out_of_bounds;
    check_bounds result;
    result

  let sub a b =
    let result = a - b in
    (* Inlined overflow check for subtraction *)
    let a_nonneg = P.Type.compare a zero >= 0 in
    let b_neg = P.Type.compare b zero < 0 in
    let result_neg = P.Type.compare result zero < 0 in
    (* If a >= 0 and b < 0, then a - b should be >= a >= 0 *)
    if a_nonneg && b_neg && result_neg then raise Out_of_bounds;
    (* If a < 0 and b >= 0, then a - b should be <= a < 0 *)
    if not a_nonneg && not b_neg && not result_neg then raise Out_of_bounds;
    check_bounds result;
    result

  let mul a b =
    let result = a * b in
    (* Inlined overflow check for multiplication *)
    let a_neg = P.Type.compare a zero < 0 in
    let b_neg = P.Type.compare b zero < 0 in
    let result_neg = P.Type.compare result zero < 0 in
    (* XOR of operand signs should match result sign (unless result is 0) *)
    let signs_match = (a_neg && b_neg && not result_neg) || 
                      (a_neg && not b_neg && result_neg) ||
                      (not a_neg && b_neg && result_neg) ||
                      (not a_neg && not b_neg && not result_neg) in
    if not signs_match && P.Type.compare result zero <> 0 then raise Out_of_bounds;
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
    (* Inlined overflow check for negation *)
    (* Negation: if a is min_value, then -a would overflow in two's complement *)
    if P.Type.compare a P.Type.min_value = 0 && P.Type.compare result zero <> 0 then
      raise Out_of_bounds;
    check_bounds result;
    result

  let abs a =
    if P.Type.compare a zero < 0 then begin
      let result = ~- a in
      (* Inlined overflow check for negation in abs *)
      if P.Type.compare a P.Type.min_value = 0 && P.Type.compare result zero <> 0 then
        raise Out_of_bounds;
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
