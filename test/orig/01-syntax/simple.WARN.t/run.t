Instrument with vlt.ppx:
  $ dune describe pp simple.ml 2> /dev/null | tail -n 36
  let () = Vlt.Logger.prepare "Simple"
  let main () =
    ();
    if (Array.length Sys.argv) = 0
    then
      (if Vlt.Logger.check_level "Simple.main" Vlt.Level.WARN
       then
         Vlt.Logger.log "Simple.main" Vlt.Level.WARN ~file:"simple.ml" ~line:6
           ~column:4 ~properties:[] ~error:None
           (Printf.sprintf "no %s" "argument")
       else ());
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
