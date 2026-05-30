(lang dune 3.23)

(name bounded_integer)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Roland Laznik <dev@lznk.de>")

(maintainers "Maintainer Name <maintainer@example.com>")

(license MIT)

(documentation https://url/to/documentation)

(package
 (name bounded_integer)
 (synopsis "A short synopsis")
 (description "A longer description")
 (tags
  ("add topics" "to describe" your project))
 (depends 
   (ocaml (>= 5.4.1))
   base
 )
)

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
