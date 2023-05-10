Instrument with vlt.ppx:
  $ dune describe pp formatting.ml
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
    ();
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
    ();
    ();
    ();
    ();
    ()

