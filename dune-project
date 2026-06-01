(lang dune 3.23)

(name bounded_integer)

(generate_opam_files true)

(source
 (github devlznk/ocaml_bounded_integer))

(authors "Roland Laznik <dev@lznk.de>")

(license MIT)

(package
 (name bounded_integer)
 (version 0.2.2)
 (synopsis "BoundedInteger module functor.")
 (description "A functor-based library for creating type-safe bounded integer
 types with compile-time optimized range checking on all arithmetic operations.")
 (depends
   (ocaml (>= 5.4.1))
   base
 )
)
