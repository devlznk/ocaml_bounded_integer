(** Bounded integer library - Implementation *)

exception Out_of_bounds

include Bounded_integer_types

(** The functor implementation. 
    
    See the interface ({!module:Bounded_integer}) for documentation.
    
    Overflow/underflow checks are conditionally included based on compile-time
    analysis of the bounds. If the bounds are sufficiently small that overflow
    is impossible, the checks are omitted.
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
  
  (* For addition: overflow possible if 2*upper > max_value or 2*lower < min_value *)
  let half_max = P.Type.max_value / two
  let half_min = P.Type.min_value / two
  let check_add_overflow =
    P.Type.compare P.upper half_max > 0 || P.Type.compare P.lower half_min < 0

  (* For subtraction: overflow possible if range > max_value - min_value *)
  let range = P.upper - P.lower
  let check_sub_overflow =
    P.Type.compare range P.Type.max_value > 0 || 
    P.Type.compare range P.Type.min_value < 0

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
      (* Inlined overflow check for addition *)
      let a_nonneg = P.Type.compare a zero >= 0 in
      let b_nonneg = P.Type.compare b zero >= 0 in
      let result_neg = P.Type.compare result zero < 0 in
      if a_nonneg && b_nonneg && result_neg then raise Out_of_bounds;
      if not a_nonneg && not b_nonneg && not result_neg then raise Out_of_bounds
    end;
    check_bounds result;
    result

  let sub a b =
    let result = a - b in
    if check_sub_overflow then begin
      (* Inlined overflow check for subtraction *)
      let a_nonneg = P.Type.compare a zero >= 0 in
      let b_neg = P.Type.compare b zero < 0 in
      let result_neg = P.Type.compare result zero < 0 in
      if a_nonneg && b_neg && result_neg then raise Out_of_bounds;
      if not a_nonneg && not b_neg && not result_neg then raise Out_of_bounds
    end;
    check_bounds result;
    result

  let mul a b =
    let result = a * b in
    if check_mul_overflow then begin
      (* Inlined overflow check for multiplication *)
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
