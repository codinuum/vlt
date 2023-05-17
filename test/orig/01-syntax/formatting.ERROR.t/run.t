Instrument with vlt.ppx:
  $ dune describe pp formatting.ml 2> /dev/null
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

