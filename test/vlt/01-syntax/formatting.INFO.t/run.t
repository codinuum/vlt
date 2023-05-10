Instrument with vlt.ppx:
  $ dune describe pp --instrument-with vlt.ppx formatting.ml
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
  let () = Vlt.Logger.prepare "Formatting"
  let () =
    if Vlt.Logger.check_level "Formatting" Vlt.Level.FATAL
    then
      Vlt.Logger.logf "Formatting" Vlt.Level.FATAL ~file:"formatting.ml"
        ~line:4 ~column:2 ~properties:[] ~error:None "no parameter"
    else ();
    if Vlt.Logger.check_level "Formatting" Vlt.Level.INFO
    then
      Vlt.Logger.logf "Formatting" Vlt.Level.INFO ~file:"formatting.ml" ~line:5
        ~column:2 ~properties:[] ~error:None "one parameter: %d" 1
    else ();
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
    if Vlt.Logger.check_level "Formatting" Vlt.Level.INFO
    then
      Vlt.Logger.logf "Formatting" Vlt.Level.INFO ~file:"formatting.ml"
        ~line:16 ~column:2 ~properties:[] ~error:None "one parameter: %d"
        (id 1)
    else ();
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

