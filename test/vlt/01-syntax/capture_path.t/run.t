We can instrument with vlt.ppx:
  $ dune describe pp test.ml
  [@@@ocaml.ppx.context
    {
      tool_name = "ppx_driver";
      include_dirs = [];
      load_path = [];
      open_modules = [];
      for_package = None;
      debug = false;
      use_threads = false;
      use_vmthreads = false;
      recursive_types = false;
      principal = false;
      transparent_modules = false;
      unboxed_types = false;
      unsafe_string = false;
      cookies = []
    }]
  let () = Vlt.Logger.prepare "Test"
  class foo =
    object
      method m0 x =
        let y =
          if Vlt.Logger.check_level "Test" Vlt.Level.DEBUG
          then
            Vlt.Logger.logf "Test" Vlt.Level.DEBUG ~file:"test.ml" ~line:6
              ~column:6 ~properties:[] ~error:None "x=%d" x
          else ();
          x + 1 in
        y
    end
  module A =
    struct
      module B =
        struct
          let f0 x =
            if Vlt.Logger.check_level "Test.A.B" Vlt.Level.DEBUG
            then
              Vlt.Logger.logf "Test.A.B" Vlt.Level.DEBUG ~file:"test.ml"
                ~line:17 ~column:6 ~properties:[] ~error:None "x=%d" x
            else ();
            x + 1
          class bar =
            object
              method m1 (type s) cmp =
                let module S =
                  (Set.Make)(struct
                               type t = s
                               let compare x y =
                                 if
                                   Vlt.Logger.check_level "Test.A.B"
                                     Vlt.Level.DEBUG
                                 then
                                   Vlt.Logger.logf "Test.A.B" Vlt.Level.DEBUG
                                     ~file:"test.ml" ~line:25 ~column:12
                                     ~properties:[] ~error:None "@"
                                 else ();
                                 cmp x y
                             end) in ((module
                  S) : (module Set.S with type elt = s))
            end
        end
    end
  let main () =
    if Vlt.Logger.check_level "Test" Vlt.Level.DEBUG
    then
      Vlt.Logger.logf "Test" Vlt.Level.DEBUG ~file:"test.ml" ~line:36 ~column:2
        ~properties:[] ~error:None "@"
    else ()
  class foo =
    object
      method m0 x =
        let y =
          if Vlt.Logger.check_level "Test.foo#m0.y" Vlt.Level.DEBUG
          then
            Vlt.Logger.logf "Test.foo#m0.y" Vlt.Level.DEBUG ~file:"test.ml"
              ~line:42 ~column:6 ~properties:[] ~error:None "x=%d" x
          else ();
          x + 1 in
        y
    end
  module A =
    struct
      module B =
        struct
          let f0 x =
            if Vlt.Logger.check_level "Test.A.B.f0" Vlt.Level.DEBUG
            then
              Vlt.Logger.logf "Test.A.B.f0" Vlt.Level.DEBUG ~file:"test.ml"
                ~line:55 ~column:6 ~properties:[] ~error:None "x=%d" x
            else ();
            x + 1
          class bar =
            object
              method m1 (type s) cmp =
                let module S =
                  (Set.Make)(struct
                               type t = s
                               let compare x y =
                                 if
                                   Vlt.Logger.check_level
                                     "Test.A.B.bar#m1.S.compare"
                                     Vlt.Level.DEBUG
                                 then
                                   Vlt.Logger.logf "Test.A.B.bar#m1.S.compare"
                                     Vlt.Level.DEBUG ~file:"test.ml" ~line:63
                                     ~column:12 ~properties:[] ~error:None "@"
                                 else ();
                                 cmp x y
                             end) in ((module
                  S) : (module Set.S with type elt = s))
            end
        end
    end
  let main () =
    if Vlt.Logger.check_level "Test.main" Vlt.Level.DEBUG
    then
      Vlt.Logger.logf "Test.main" Vlt.Level.DEBUG ~file:"test.ml" ~line:76
        ~column:2 ~properties:[] ~error:None "@"
    else ()
