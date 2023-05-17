Instrument with vlt.ppx:
  $ dune describe pp simple.ml 2> /dev/null
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
  let () = Vlt.Logger.prepare "Simple"
  let main () =
    ();
    if (Array.length Sys.argv) = 0 then ();
    for i = 1 to pred (Array.length Sys.argv) do
      (try (); print_endline (Sys.getenv (Sys.argv.(i)))
       with
       | Not_found ->
           if Vlt.Logger.check_level "Simple.main" Vlt.Level.ERROR
           then
             Vlt.Logger.log "Simple.main" Vlt.Level.ERROR ~file:"simple.ml"
               ~line:13 ~column:8
               ~properties:(let open Vlt in [("var", (Sys.argv.(i)))])
               ~error:None "undefined variable"
           else ())
    done;
    ()
  let () =
    ();
    (try main ()
     with
     | e ->
         (if Vlt.Logger.check_level "Simple" Vlt.Level.FATAL
          then
            Vlt.Logger.log "Simple" Vlt.Level.FATAL ~file:"simple.ml" ~line:22
              ~column:4 ~properties:[] ~error:(Some e) "uncaught exception"
          else ();
          Printexc.print_backtrace stdout));
    ()
