We can instrument with vlt.ppx:
  $ dune describe pp test.ml 2> /dev/null | tail -n 20
  let () = Vlt.Logger.prepare "Test"
  let () =
    if Vlt.Logger.check_level "Test" Vlt.Level.INFO
    then
      (Printf.printf "FOO\n";
       Vlt.Logger.logf "Test" Vlt.Level.INFO ~file:"test.ml" ~line:6 ~column:4
         ~properties:[] ~error:None "BAR";
       if Vlt.Logger.check_level "Test" Vlt.Level.DEBUG
       then
         Vlt.Logger.logf "Test" Vlt.Level.DEBUG ~file:"test.ml" ~line:7
           ~column:4 ~properties:[] ~error:None "BAZ"
       else ())
    else ()
  let () =
    if Vlt.Logger.check_level "Test" Vlt.Level.DEBUG
    then
      Vlt.Logger.log "Test" Vlt.Level.WARN ~file:"test.ml" ~line:11 ~column:2
        ~properties:[] ~error:None "FOO"
    else ()
  let () = ()
