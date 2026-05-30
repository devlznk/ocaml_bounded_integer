exception Out_of_bounds

module BoundedInteger : functor (P : sig
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
  end) -> sig
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
