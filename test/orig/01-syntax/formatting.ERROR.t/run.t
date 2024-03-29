Instrument with vlt.ppx:
  $ dune describe pp formatting.ml 2> /dev/null | tail -n 36
  let () = Vlt.Logger.prepare "Formatting"
  let () =
    if Vlt.Logger.check_level "Formatting" Vlt.Level.FATAL
    then
      Vlt.Logger.log "Formatting" Vlt.Level.FATAL ~file:"formatting.ml" ~line:4
        ~column:2 ~properties:[] ~error:None "no parameter"
    else ();
    ();
    if Vlt.Logger.check_level "Formatting" Vlt.Level.ERROR
    then
      Vlt.Logger.log "Formatting" Vlt.Level.ERROR ~file:"formatting.ml" ~line:6
        ~column:2 ~properties:[] ~error:None
        (Printf.sprintf "two parameters: %d %s" 1 "abc")
    else ();
    ();
    ();
    ();
    ()
  let id x = x
  let () =
    if Vlt.Logger.check_level "Formatting" Vlt.Level.FATAL
    then
      Vlt.Logger.log "Formatting" Vlt.Level.FATAL ~file:"formatting.ml"
        ~line:15 ~column:2 ~properties:[] ~error:None "no parameter"
    else ();
    ();
    if Vlt.Logger.check_level "Formatting" Vlt.Level.ERROR
    then
      Vlt.Logger.log "Formatting" Vlt.Level.ERROR ~file:"formatting.ml"
        ~line:17 ~column:2 ~properties:[] ~error:None
        (Printf.sprintf "two parameters: %d %s" 1 (id "abc"))
    else ();
    ();
    ();
    ();
    ()

