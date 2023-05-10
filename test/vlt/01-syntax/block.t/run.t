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
