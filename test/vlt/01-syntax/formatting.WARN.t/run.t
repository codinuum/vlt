Instrument with vlt.ppx:
  $ dune describe pp formatting.ml 2> /dev/null | tail -n 46
  let () = Vlt.Logger.prepare "Formatting"
  let () =
    if Vlt.Logger.check_level "Formatting" Vlt.Level.FATAL
    then
      Vlt.Logger.logf "Formatting" Vlt.Level.FATAL ~file:"formatting.ml"
        ~line:4 ~column:2 ~properties:[] ~error:None "no parameter"
    else ();
    ();
    if Vlt.Logger.check_level "Formatting" Vlt.Level.ERROR
    then
      Vlt.Logger.logf "Formatting" Vlt.Level.ERROR ~file:"formatting.ml"
        ~line:6 ~column:2 ~properties:[] ~error:None "two parameters: %d %s" 1
        "abc"
    else ();
    ();
    if Vlt.Logger.check_level "Formatting" Vlt.Level.WARN
    then
      Vlt.Logger.logf "Formatting" Vlt.Level.WARN ~file:"formatting.ml" ~line:8
        ~column:2 ~properties:[] ~error:None "four parameters: %d %s %f %B" 1
        "abc" 3. true
    else ();
    ();
    ()
  let id x = x
  let () =
    if Vlt.Logger.check_level "Formatting" Vlt.Level.FATAL
    then
      Vlt.Logger.logf "Formatting" Vlt.Level.FATAL ~file:"formatting.ml"
        ~line:15 ~column:2 ~properties:[] ~error:None "no parameter"
    else ();
    ();
    if Vlt.Logger.check_level "Formatting" Vlt.Level.ERROR
    then
      Vlt.Logger.logf "Formatting" Vlt.Level.ERROR ~file:"formatting.ml"
        ~line:17 ~column:2 ~properties:[] ~error:None "two parameters: %d %s" 1
        (id "abc")
    else ();
    ();
    if Vlt.Logger.check_level "Formatting" Vlt.Level.WARN
    then
      Vlt.Logger.logf "Formatting" Vlt.Level.WARN ~file:"formatting.ml"
        ~line:19 ~column:2 ~properties:[] ~error:None
        "four parameters: %d %s %f %B" 1 "abc" 3. (id true)
    else ();
    ();
    ()

