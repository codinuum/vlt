We can instrument with vlt.ppx:
  $ dune describe pp test.ml 2> /dev/null | tail -n 134
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
      initializer
        if Vlt.Logger.check_level "Test" Vlt.Level.DEBUG
        then
          Vlt.Logger.logf "Test" Vlt.Level.DEBUG ~file:"test.ml" ~line:12
            ~column:4 ~properties:[] ~error:None "init"
        else ()
    end
  module A =
    struct
      module B =
        struct
          let f0 x =
            if Vlt.Logger.check_level "Test.A.B" Vlt.Level.DEBUG
            then
              Vlt.Logger.logf "Test.A.B" Vlt.Level.DEBUG ~file:"test.ml"
                ~line:20 ~column:6 ~properties:[] ~error:None "x=%d" x
            else ();
            x + 1
          class bar =
            object (self)
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
                                     ~file:"test.ml" ~line:28 ~column:12
                                     ~properties:[] ~error:None "@"
                                 else ();
                                 cmp x y
                             end) in ((module
                  S) : (module Set.S with type elt = s))
              initializer
                if Vlt.Logger.check_level "Test.A.B" Vlt.Level.DEBUG
                then
                  Vlt.Logger.logf "Test.A.B" Vlt.Level.DEBUG ~file:"test.ml"
                    ~line:34 ~column:8 ~properties:[] ~error:None "init"
                else ();
                (let _ = self#m1 (fun x y -> (f0 x) + ((new foo)#m0 y)) in ())
            end
        end
    end
  let main () =
    if Vlt.Logger.check_level "Test" Vlt.Level.DEBUG
    then
      Vlt.Logger.logf "Test" Vlt.Level.DEBUG ~file:"test.ml" ~line:44 ~column:2
        ~properties:[] ~error:None "@"
    else ();
    (let _ = new A.B.bar in ())
  let _ = main ()
  class foo2 =
    object
      method m0 x =
        let y =
          if Vlt.Logger.check_level "Test.foo2#m0.y" Vlt.Level.DEBUG
          then
            Vlt.Logger.logf "Test.foo2#m0.y" Vlt.Level.DEBUG ~file:"test.ml"
              ~line:55 ~column:6 ~properties:[] ~error:None "x=%d" x
          else ();
          x + 1 in
        y
      initializer
        if Vlt.Logger.check_level "Test.foo2#<init>" Vlt.Level.DEBUG
        then
          Vlt.Logger.logf "Test.foo2#<init>" Vlt.Level.DEBUG ~file:"test.ml"
            ~line:61 ~column:4 ~properties:[] ~error:None "init"
        else ()
    end
  module A2 =
    struct
      module B =
        struct
          let f0 x =
            if Vlt.Logger.check_level "Test.A2.B.f0" Vlt.Level.DEBUG
            then
              Vlt.Logger.logf "Test.A2.B.f0" Vlt.Level.DEBUG ~file:"test.ml"
                ~line:71 ~column:6 ~properties:[] ~error:None "x=%d" x
            else ();
            x + 1
          class bar =
            object (self)
              method m1 (type s) cmp =
                let module S =
                  (Set.Make)(struct
                               type t = s
                               let compare x y =
                                 if
                                   Vlt.Logger.check_level
                                     "Test.A2.B.bar#m1.S.compare"
                                     Vlt.Level.DEBUG
                                 then
                                   Vlt.Logger.logf "Test.A2.B.bar#m1.S.compare"
                                     Vlt.Level.DEBUG ~file:"test.ml" ~line:79
                                     ~column:12 ~properties:[] ~error:None "@"
                                 else ();
                                 cmp x y
                             end) in ((module
                  S) : (module Set.S with type elt = s))
              initializer
                if
                  Vlt.Logger.check_level "Test.A2.B.bar#<init>" Vlt.Level.DEBUG
                then
                  Vlt.Logger.logf "Test.A2.B.bar#<init>" Vlt.Level.DEBUG
                    ~file:"test.ml" ~line:85 ~column:8 ~properties:[]
                    ~error:None "init"
                else ();
                (let _ = self#m1 (fun x y -> (f0 x) + ((new foo2)#m0 y)) in ())
            end
        end
    end
  let main () =
    if Vlt.Logger.check_level "Test.main" Vlt.Level.DEBUG
    then
      Vlt.Logger.logf "Test.main" Vlt.Level.DEBUG ~file:"test.ml" ~line:97
        ~column:2 ~properties:[] ~error:None "@"
    else ();
    (let _ = new A2.B.bar in ())
  let _ = main ()
