(lang dune 3.7)

(name vlt)

;(version 0.1)

(generate_opam_files true)

(source (github codinuum/vlt))

(authors "Xavier Clerc" "Codinuum")

(maintainers "codinuum@me.com")

(license LGPL-3.0-only)

(documentation https://github.com/codinuum/vlt/README.md)

(package
 (name vlt)
 (synopsis "A variant of Bolt logging tool")
 (description "Vlt is yet another variant of Bolt logging tool derived from Volt.
Unlike Volt, Vlt relies on ppx instead of camlp4 to preprocess source code.")
 (depends
  (ocaml (>= 4.14))
  dune
  (ppxlib (>= 0.29))
  (ocamlfind :with-test)
 )
 (tags (logging))
)
