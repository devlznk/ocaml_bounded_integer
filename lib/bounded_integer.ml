exception Out_of_bounds

module BoundedInteger (P : sig
    module Type : sig
      type t
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

  let of_int n =
    let result = P.Type.of_int n in
    if P.Type.compare result P.lower < 0 || P.Type.compare result P.upper > 0 then
      raise Out_of_bounds
    else
      result

  let check_bounds x =
    if P.Type.compare x P.lower < 0 || P.Type.compare x P.upper > 0 then
      raise Out_of_bounds
    else
      x

  let zero = P.Type.of_int 0

  let add a b =
    let result = a + b in
    check_bounds result

  let sub a b =
    let result = a - b in
    check_bounds result

  let mul a b =
    let result = a * b in
    check_bounds result

  let div a b =
    let result = a / b in
    check_bounds result

  let rem a b =
    let result = a - (a / b) * b in
    check_bounds result

  let neg a =
    let result = ~- a in
    check_bounds result

  let abs a =
    let result = if P.Type.compare a zero < 0 then ~- a else a in
    check_bounds result

  let ( + ) = add
  let ( - ) = sub
  let ( * ) = mul
  let ( / ) = div
  let ( ~- ) = neg
  let compare = P.Type.compare
end
