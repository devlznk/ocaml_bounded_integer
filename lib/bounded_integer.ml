exception Out_of_bounds

module BoundedInteger (P : sig
    module Type : sig
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
    end
    val lower : Type.t
    val upper : Type.t
  end) : sig
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
  end = struct
  open P.Type
  type t = P.Type.t

  let min_value = P.lower
  let max_value = P.upper

  let check_type_bounds x =
    if P.Type.compare x P.Type.min_value < 0 || P.Type.compare x P.Type.max_value > 0 then
      raise Out_of_bounds

  let check_bounds x =
    if P.Type.compare x P.lower < 0 || P.Type.compare x P.upper > 0 then
      raise Out_of_bounds

  let of_int n =
    let result = P.Type.of_int n in
    check_type_bounds result;
    check_bounds result;
    result

  let zero = P.Type.of_int 0

  let add a b =
    let result = a + b in
    check_type_bounds result;
    check_bounds result;
    result

  let sub a b =
    let result = a - b in
    check_type_bounds result;
    check_bounds result;
    result

  let mul a b =
    let result = a * b in
    check_type_bounds result;
    check_bounds result;
    result

  let div a b =
    let result = a / b in
    check_type_bounds result;
    check_bounds result;
    result

  let rem a b =
    let result = a - (a / b) * b in
    check_type_bounds result;
    check_bounds result;
    result

  let neg a =
    let result = ~- a in
    check_type_bounds result;
    check_bounds result;
    result

  let abs a =
    let result = if P.Type.compare a zero < 0 then ~- a else a in
    check_type_bounds result;
    check_bounds result;
    result

  let ( + ) = add
  let ( - ) = sub
  let ( * ) = mul
  let ( / ) = div
  let ( ~- ) = neg
  let compare = P.Type.compare
end
