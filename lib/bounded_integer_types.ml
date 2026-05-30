(** Bounded integer library - Type definitions *)

(** The signature for integer type modules like [Base.Int] or [Base.Int63]. *)
module type INT_TYPE = sig
  (** The integer type. *)
  type t
  
  (** Minimum value for this integer type. *)
  val min_value : t
  
  (** Maximum value for this integer type. *)
  val max_value : t
  
  (** Addition operator. *)
  val ( + ) : t -> t -> t
  
  (** Subtraction operator. *)
  val ( - ) : t -> t -> t
  
  (** Multiplication operator. *)
  val ( * ) : t -> t -> t
  
  (** Division operator. *)
  val ( / ) : t -> t -> t
  
  (** Negation operator. *)
  val ( ~- ) : t -> t
  
  (** Comparison function. Returns -1, 0, or 1. *)
  val compare : t -> t -> int
  
  (** Convert from integer. *)
  val of_int : int -> t
  
  (** Bitwise XOR function. Required for efficient overflow detection. *)
  val bit_xor : t -> t -> t
  
  (** Bitwise AND function. Required for efficient overflow detection. *)
  val bit_and : t -> t -> t
end

(** Parameters for the [BoundedInteger] functor. *)
module type BOUNDED_INTEGER_PARAMS = sig
  (** The underlying integer type module. *)
  module Type : INT_TYPE
  
  (** Lower bound (inclusive). *)
  val lower : Type.t
  
  (** Upper bound (inclusive). *)
  val upper : Type.t
end

(** Result signature of the [BoundedInteger] functor. *)
module type BOUNDED_INTEGER_RESULT = sig
  (** The bounded integer type. *)
  type t
  
  (** Minimum value of the bounded range. Same as [lower] from params. *)
  val min_value : t
  
  (** Maximum value of the bounded range. Same as [upper] from params. *)
  val max_value : t
  
  (** Create a bounded integer from an integer. 
      Raises [Out_of_bounds] if the value is outside [lower, upper]. *)
  val of_int : int -> t
  
  (** Addition with bounds checking. 
      Checks for both low-level overflow and user bounds. 
      Raises [Out_of_bounds] on violation. *)
  val add : t -> t -> t
  
  (** Subtraction with bounds checking. 
      Checks for both low-level overflow and user bounds. 
      Raises [Out_of_bounds] on violation. *)
  val sub : t -> t -> t
  
  (** Multiplication with bounds checking. 
      Checks for both low-level overflow and user bounds. 
      Raises [Out_of_bounds] on violation. *)
  val mul : t -> t -> t
  
  (** Division with bounds checking. 
      Raises [Out_of_bounds] if result is outside user bounds. *)
  val div : t -> t -> t
  
  (** Remainder with bounds checking. 
      Raises [Out_of_bounds] if result is outside user bounds. *)
  val rem : t -> t -> t
  
  (** Negation with bounds checking. 
      Checks for both low-level overflow and user bounds. 
      Raises [Out_of_bounds] on violation. *)
  val neg : t -> t
  
  (** Absolute value with bounds checking. 
      Checks for both low-level overflow and user bounds. 
      Raises [Out_of_bounds] on violation. *)
  val abs : t -> t
  
  (** Addition operator. *)
  val ( + ) : t -> t -> t
  
  (** Subtraction operator. *)
  val ( - ) : t -> t -> t
  
  (** Multiplication operator. *)
  val ( * ) : t -> t -> t
  
  (** Division operator. *)
  val ( / ) : t -> t -> t
  
  (** Negation operator. *)
  val ( ~- ) : t -> t
  
  (** Comparison function. Returns -1, 0, or 1. *)
  val compare : t -> t -> int
end
