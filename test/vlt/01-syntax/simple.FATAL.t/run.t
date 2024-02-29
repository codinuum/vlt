Instrument with vlt.ppx:
  $ dune describe pp simple.ml 2> /dev/null | tail -n 20
  let () = Vlt.Logger.prepare "Simple"
  let main () =
    ();
    if (Array.length Sys.argv) = 0 then ();
    for i = 1 to pred (Array.length Sys.argv) do
      (try (); print_endline (Sys.getenv (Sys.argv.(i))) with | Not_found -> ())
    done;
    ()
  let () =
    ();
    (try main ()
     with
     | e ->
         (if Vlt.Logger.check_level "Simple" Vlt.Level.FATAL
          then
            Vlt.Logger.logf "Simple" Vlt.Level.FATAL ~file:"simple.ml" ~line:22
              ~column:4 ~properties:[] ~error:(Some e) "uncaught exception"
          else ();
          Printexc.print_backtrace stdout));
    ()
